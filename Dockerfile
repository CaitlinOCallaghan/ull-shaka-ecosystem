FROM ubuntu:20.04 as shaka_ubuntu2004_baseline
LABEL org.opencontainers.image.authors="kevleyski"

# Pull in build cross compiler tool dependencies using Advanced Package Tool
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update

EXPOSE 80

RUN set -x \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install wget curl autoconf automake build-essential libass-dev libfreetype6-dev \
                                            libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
                                            libxcb-xfixes0-dev pkg-config texinfo zlib1g-dev gettext tcl libssl-dev cmake mercurial unzip git \
                                            libdrm-dev valgrind libpciaccess-dev libxslt1-dev geoip-bin libgeoip-dev zlib1g-dev libpcre3 libpcre3-dev \
                                            libbz2-dev ca-certificates libssl-dev nasm v4l-utils libv4l-dev gtk2.0 snapd

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

WORKDIR /root/ull-shaka-ecosystem

COPY ./demo /root/ull-shaka-ecosystem/demo
COPY ./test-content /root/ull-shaka-ecosystem/test-content

FROM shaka_ubuntu2004_baseline AS shaka_baseline_ecosystem

# Google Depot Tools
RUN set -x \
    && mkdir -p /var/www/ \
    && chown -R "$USER" /var/www/ \
    && chmod 755 -R /var/www/ \
    && if [ ! -d "depot_tools" ]; then git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git depot_tools; fi

ARG PASS_GYP_DEFINES
ENV GYP_DEFINES="$PASS_GYP_DEFINES"

# Shaka Packager with HTTP upload
# Grab shaka-packager fork  the fork that contains ULL work
# Checkout the main branch
# NOTE: use "gclinet sync -r {commit_hash}" to checkout a specific commit or branch
# Build shaka-packager
# Save the binary file to local bin for global use
RUN set -x \
    && export PATH="$PATH:/root/ull-shaka-ecosystem/depot_tools" \
    && export GYP_DEFINES="$PASS_GYP_DEFINES" \
    && echo "KJSL: GYP_DEFINES=$GYP_DEFINES" \
    && mkdir -p /root/ull-shaka-ecosystem/shaka-packager \
    && cd /root/ull-shaka-ecosystem/shaka-packager \
    && gclient config https://github.com/CaitlinOCallaghan/shaka-packager.git --name=src --unmanaged \
    && gclient sync \
    && cd /root/ull-shaka-ecosystem/shaka-packager/src \
    && ninja -C out/Release \
    && ./out/Release/packager --version \
    && install -m 755 ./out/Release/packager /usr/local/bin/packager

# Clone Shaka Streamer
# Install google-cloud-sdk
# s3-upload-proxy for HTTP PUT to S3/MediaStore
# Checkout working commit - main does not work for mediastore
RUN set -x \
    && git clone https://github.com/CaitlinOCallaghan/shaka-streamer.git \
    && curl https://dl.google.com/dl/cloudsdk/release/install_google_cloud_sdk.bash | bash \
    && git clone https://github.com/fsouza/s3-upload-proxy.git \
    && cd /root/ull-shaka-ecosystem/s3-upload-proxy \
    && git checkout 793d1164921d6e42b4bec26686e76001995f218b
