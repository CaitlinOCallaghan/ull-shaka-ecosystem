FROM ubuntu:20.04 as shaka_ubuntu2004_baseline
MAINTAINER kevleyski

# Pull in build cross compiler tool dependencies using Advanced Package Tool
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update

RUN set -x \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install wget curl autoconf automake build-essential libass-dev libfreetype6-dev \
                                            libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
                                            libxcb-xfixes0-dev pkg-config texinfo zlib1g-dev gettext tcl libssl-dev cmake mercurial unzip git \
                                            libdrm-dev valgrind libpciaccess-dev libxslt1-dev geoip-bin libgeoip-dev zlib1g-dev libpcre3 libpcre3-dev \
                                            libbz2-dev ca-certificates libssl-dev nasm v4l-utils libv4l-dev gtk2.0

RUN set -x \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install \
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

COPY . shaka

FROM shaka_ubuntu2004_baseline AS shaka_baseline_ecosystem

# ImageMagic (v6 - note _not_ v7)
RUN set -x \
    && chown -R "$USER" /var/www/ \
    && sudo chmod 755 -R /var/www/

# Shaka Packager with HTTP upload
# Grab shaka-packager fork  the fork that contains ULL work
# Checkout the main branch
# NOTE: use "gclinet sync -r {commit_hash}" to checkout a specific commit or branch
# Build shaka-packager
# Save the binary file to local bin for global use
RUN set -x \
    && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git \
    && export PATH="$PATH:$PWD/depot_tools" \
    && mkdir shaka-packager \
    && cd shaka-packager \
    && gclient config https://github.com/CaitlinOCallaghan/shaka-packager.git --name=src --unmanaged \
    && gclient sync \
    && cd src \
    && ninja -C out/Release \
    && ./out/Release/packager --version \
    && sudo install -m 755 ./out/Release/packager  /usr/local/bin/packager \

# Clone Shaka Streamer
# Install google-cloud-sdk
# s3-upload-proxy for HTTP PUT to S3/MediaStore
# Checkout working commit - main does not work for mediastore
RUN set -x \
    && git clone https://github.com/CaitlinOCallaghan/shaka-streamer.git \
    && sudo snap install google-cloud-sdk --classic \
    && git clone https://github.com/fsouza/s3-upload-proxy.git \
    && cd s3-upload-proxy \
    && git checkout 793d1164921d6e42b4bec26686e76001995f218b
