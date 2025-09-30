# Run Autoware in Docker

## Build

```bash
cd autoware

# One-time (if you haven’t already):
docker buildx create --use --name awbuilder
docker buildx inspect --bootstrap

# Build for your current platform and load into the local docker image store:
docker buildx build --progress=plain \
  --build-arg DEBUG_BUST="$(date +%s)" \
  -t autoware-base \
  -f docker-new/autoware-base.Dockerfile \
  --load \
  .

```

## Usage

```bash
docker run --rm -it \
--net host \
--user $(id -u):$(id -g) \
-v $HOME/projects/autoware:/home/aw/autoware \
autoware-base
```