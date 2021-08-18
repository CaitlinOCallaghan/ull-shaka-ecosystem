#!/bin/bash

export ARCH=$(uname -m)

export GOLANG_ARCH=amd64
export SHAKA_PACKAGER_SOURCE="CaitlinOCallaghan"
export SHAKA_PACKAGER_COMMIT="5eda83ee491acb992de6f138ecf621370717ca73"
export SHAKA_PACKAGER_BINARY="v2_packagerX861804.tar.gz"

if [[ $ARCH == "aarch64" ]]; then
  export GOLANG_ARCH=arm64
  export SHAKA_PACKAGER_BINARY="v2_packagerArm1804.tar.gz"
fi

# Server build script for Ubuntu 20.04

sudo apt-get -y update

sudo apt-get -y upgrade

sudo apt-get -y install \
  awscli \
  build-essential \
  cmake \
  curl \
  git \
  htop \
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
  terminator \
  wget 

if [[ $ARCH == "x86_64" ]]; then
  sudo apt-get -y install ffmpeg
fi

sudo chown -R "$USER" /var/www/
sudo chmod 755 -R /var/www/

# Shaka Packager
wget wget "https://github.com/CaitlinOCallaghan/ull-shaka-ecosystem/releases/download/v2/${SHAKA_PACKAGER_BINARY}"
sudo tar -C /usr/local/bin -xzf "${SHAKA_PACKAGER_BINARY}" 

# Shaka Streamer
git clone https://github.com/CaitlinOCallaghan/shaka-streamer.git
sudo snap install google-cloud-sdk --classic

# s3-upload-proxy for HTTP PUT to S3/MediaStore
git clone https://github.com/fsouza/s3-upload-proxy.git

# install go - a dependency for s3-upload-proxy
wget "https://golang.org/dl/go1.16.7.linux-$GOLANG_ARCH.tar.gz"
sudo tar -C /usr/local -xzf "go1.16.7.linux-$GOLANG_ARCH.tar.gz"
export PATH=$PATH:/usr/local/go/bin
sudo install -m 755 /usr/local/go/bin/go  /usr/local/bin/go
go version

# install low-latency-preview which contains a ULL server
git clone https://github.com/CaitlinOCallaghan/low-latency-preview.git
cd low-latency-preview
# checkout branch containing ARM support
git checkout arm-support
./buildEncoderAndServerArm.sh
cd ..
