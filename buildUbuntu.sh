#!/bin/bash

export ARCH=$(uname -m)

export GOLANG_ARCH=amd64
export SHAKA_PACKAGER_SOURCE="CaitlinOCallaghan"
export SHAKA_PACKAGER_COMMIT="45e92b4b9fdfdcb6842f891886d09f52ecb2ef73"

if [[ $ARCH == "aarch64" ]]; then
  export GOLANG_ARCH=arm64
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

# Shaka Packager with LL-DASH support
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$PATH:$PWD/depot_tools"
mkdir shaka-packager
cd shaka-packager
# grab the fork that contains ULL work
gclient config "https://github.com/$SHAKA_PACKAGER_SOURCE/shaka-packager.git" --name=src --unmanaged
# checkout the LL-DASH branch
# NOTE: use "gclient sync -r {commit_hash}" to checkout a specific commit or branch
# otherwise, use "gclient sync" to checkout the main branch
gclient sync -r ${SHAKA_PACKAGER_COMMIT}
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

# install go - a dependency for s3-upload-proxy
wget "https://golang.org/dl/go1.15.5.linux-$GOLANG_ARCH.tar.gz"
sudo tar -C /usr/local -xzf "go1.15.5.linux-$GOLANG_ARCH.tar.gz"
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
