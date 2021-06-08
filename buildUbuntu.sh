#!/bin/bash

# Server build script for Ubuntu 20.04

sudo apt-get -y update

sudo apt-get -y upgrade

sudo apt-get -y install \
  awscli \
  build-essential \
  cmake \
  curl \
  ffmpeg \
  git \
  libncurses5 \
  libnginx-mod-http-dav-ext \
  libssl-dev \
  libtinfo5 \
  net-tools \
  nginx \
  nginx-extras \
  ninja-build \
  openssh-server \
  pkg-config \
  python \
  python3-pip \
  tclsh \
  wget 

# Shaka Packager with HTTP upload
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$PATH:$PWD/depot_tools"
mkdir shaka-packager
cd shaka-packager
# grab the repo containing the HTTP upload branch
gclient config https://github.com/CaitlinOCallaghan/shaka-packager.git --name=src --unmanaged
# checkout the HTTP branch
gclient sync -r 224b9e41822b02bfe99c74cb65c608674f1b369f
cd src
# build shaka packager
ninja -C out/Release
# verify the build
./out/Release/packager --version
# save the binary file to local bin for global use
sudo install -m 755 ./out/Release/packager  /usr/local/bin/packager
cd ../..

# Shaka Streamer
git clone https://github.com/CaitlinOCallaghan/shaka-streamer.git
sudo snap install google-cloud-sdk --classic

# s3-upload-proxy for HTTP PUT to S3/MediaStore
git clone https://github.com/fsouza/s3-upload-proxy.git
cd s3-upload-proxy
# checkout working commit - main does not work for mediastore
git checkout 793d1164921d6e42b4bec26686e76001995f218b
cd ..

# install go - a dependency for s3-upload-prxy
wget https://golang.org/dl/go1.15.5.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.15.5.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
sudo install -m 755 /usr/local/go/bin/go  /usr/local/bin/go
go version

