#!/bin/bash

ARCH=$(uname -m)

GOLANG_ARCH=amd64
SHAKA_PACKAGER_SOURCE="CaitlinOCallaghan"
if [[ $ARCH == "aarch64" ]]; then
  GYP_DEFINES="clang=0 use_allocator=none"
  GOLANG_ARCH=arm64
  SHAKA_PACKAGER_SOURCE="kevleyski" # TODO: KJSL: waiting on write access to Caitlinks shaka packager
fi

# Server build script for Ubuntu 20.04

sudo apt -y update

sudo apt -y upgrade

sudo apt -y install \
  htop \
  terminator \
  awscli \
  build-essential \
  cmake \
  ffmpeg \
  git \
  libncurses5 \
  libnginx-mod-http-dav-ext \
  libssl-dev \
  libtinfo5 \
  net-tools \
  nginx-extras \
  ninja-build \
  openssh-server \
  pkg-config \
  python \
  python3-pip \
  tcl \
  wget \
  golang-go \
  curl

sudo chown -R "$USER" /var/www/
sudo chmod 755 -R /var/www/

# Shaka Packager with HTTP upload
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$PATH:$PWD/depot_tools"
mkdir shaka-packager
cd shaka-packager
# grab the fork that contains ULL work
gclient config "https://github.com/$SHAKA_PACKAGER_SOURCE/shaka-packager.git" --name=src --unmanaged
# checkout the main branch
# NOTE: use "gclinet sync -r {commit_hash}" to checkout a specific commit or branch
gclient sync
cd src

# Build shaka-packager
ninja -C out/Release

# Verify the build
./out/Release/packager --version

# Save the binary file to local bin for global use
sudo install -m 755 ./out/Release/packager  /usr/local/bin/packager
cd ../..

# Clone Shaka Streamer
git clone https://github.com/CaitlinOCallaghan/shaka-streamer.git

# Install google-cloud-sdk
sudo snap install google-cloud-sdk --classic

# s3-upload-proxy for HTTP PUT to S3/MediaStore
git clone https://github.com/fsouza/s3-upload-proxy.git
cd s3-upload-proxy

# Checkout working commit - main does not work for mediastore
git checkout 793d1164921d6e42b4bec26686e76001995f218b
cd ..

