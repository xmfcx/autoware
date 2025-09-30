FROM ros:humble-ros-base-jammy AS ci-base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN useradd -m -s /bin/bash -U aw

RUN apt-get update && \
    apt-get install -y --no-install-recommends sudo

RUN echo "aw ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/90-user-nopasswd && \
    chmod 0440 /etc/sudoers.d/90-user-nopasswd

RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /home/aw/.bashrc && \
    chown -R aw:aw /home/aw

USER aw
WORKDIR /home/aw

RUN sudo apt-get -y install pipx && \
    python3 -m pipx ensurepath && \
    pipx install --include-deps --force "ansible==10.*"



RUN sudo rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN sudo chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
