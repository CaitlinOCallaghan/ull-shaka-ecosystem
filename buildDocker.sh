#!/bin/bash

# http://127.0.0.1:PORT/testpattern/dash.mpd
PORT=80

HERE=$PWD

IMAGE_STATE=$(docker images -q shaka_builder:latest 2> /dev/null)

create_docker_image () {
  if [[ "$IMAGE_STATE" == "" ]]; then
    echo "Building"
    docker build -t shaka_builder .
  fi
}

run_docker_container () {
  docker run --rm -it -p $PORT:80/tcp -v "$(pwd):/host" shaka_builder bash -c "/bin/bash"
}

create_docker_image
run_docker_container

# To attach to running shaka_builder...
# docker ps
# CONTAINER ID   IMAGE           COMMAND               CREATED          STATUS          PORTS                                   NAMES
# b0e63e96ec3a   shaka_builder   "bash -c /bin/bash"   21 seconds ago   Up 20 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp   strange_bose

# docker exec -i -t b0e63e96ec3a /bin/bash