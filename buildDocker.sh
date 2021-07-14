#!/bin/bash

HERE=$PWD

create_docker_image () {
  mkdir -p ./bin
  cd ./bin || exit
  docker build -t shaka_builder ..
  #docker run --rm -it -v "$(pwd):/host" shaka_builder bash -c "cp -r /root/ /host && chown $(id -u):$(id -g) /host/*"
}

run_docker_container () {
  docker run --rm -it -v "$(pwd):/host" shaka_builder bash -c "/bin/bash"
}

create_docker_image
run_docker_container
