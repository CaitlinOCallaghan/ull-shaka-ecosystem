#!/bin/bash

# Default build for same as local host
ARCH=$(uname -m)

# comment/uncomment this wanting to build ARM64 on Intel
ARCH=aarch64
#ARCH=x86_64

# http://127.0.0.1:PORT/testpattern/dash.mpd
PORT=80

HERE=$PWD

if [[ $ARCH == "aarch64" ]]; then
  # arm64
  IMAGE_STATE=$(docker images -q shaka_builder_arm:latest 2> /dev/null)

  create_docker_image () {
    if [[ "$IMAGE_STATE" == "" ]]; then
      echo "Building"
        docker buildx build --platform linux/arm64 -t shaka_builder_arm .
    fi
  }

  run_docker_container () {
    docker run --rm -it -p $PORT:80/tcp -v "$(pwd):/host" shaka_builder_arm bash -c "/bin/bash"
  }
else
  # x86_64
  IMAGE_STATE=$(docker images -q shaka_builder:latest 2> /dev/null)

  create_docker_image () {
    if [[ "$IMAGE_STATE" == "" ]]; then
      docker build -t shaka_builder .
    fi
  }

  run_docker_container () {
    docker run --rm -it -p $PORT:80/tcp -v "$(pwd):/host" shaka_builder bash -c "/bin/bash"
  }
fi

create_docker_image
run_docker_container

# To attach to running shaka_builder...
# docker ps
# CONTAINER ID   IMAGE           COMMAND               CREATED          STATUS          PORTS                                   NAMES
# b0e63e96ec3a   shaka_builder   "bash -c /bin/bash"   21 seconds ago   Up 20 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp   strange_bose

# docker exec -i -t b0e63e96ec3a /bin/bash