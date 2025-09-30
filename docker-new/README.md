# Run Autoware in Docker

## Build

```bash
cd autoware/docker-new
docker build -t autoware-base -f autoware-base.Dockerfile .
```

## Usage

```bash
docker run --rm -it \
--net host \
--user $(id -u):$(id -g) \
-v $HOME/projects/autoware:/home/aw/autoware \
autoware-base
```