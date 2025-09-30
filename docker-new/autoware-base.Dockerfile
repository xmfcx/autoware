FROM ros:humble-ros-base-jammy AS ci-base
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends sudo tree pipx bash-completion python3-argcomplete && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash -U aw && \
    echo "aw ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/90-user-nopasswd && \
    chmod 0440 /etc/sudoers.d/90-user-nopasswd && \
    sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /home/aw/.bashrc && \
    chown -R aw:aw /home/aw

USER aw
WORKDIR /home/aw

# Make pipx shims visible during build steps and at runtime
ENV PATH="/home/aw/.local/bin:${PATH}"

# Ansible via pipx
RUN python3 -m pipx ensurepath && \
    pipx install --include-deps --force "ansible==10.*"

COPY --chown=aw:aw . /home/aw/autoware
WORKDIR /home/aw/autoware

# Ansible collections + playbook
RUN ansible-galaxy collection install -f -r ansible-galaxy-requirements.yaml && \
    ansible-playbook autoware.dev_env.role_rmw_implementation \
      -e rosdistro=humble \
      -e rmw_implementation=rmw_cyclonedds_cpp

# Debug bust + quick tree
ARG DEBUG_BUST
RUN printf '%s\n' "$DEBUG_BUST" > /var/tmp/.debug-bust && \
    echo "debug bust=$DEBUG_BUST" && \
    tree -a -L 2 $HOME 1>&2

# Entrypoint
USER root
COPY docker-new/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
USER aw

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
