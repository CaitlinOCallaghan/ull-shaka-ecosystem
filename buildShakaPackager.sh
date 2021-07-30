#!/bin/bash

# This script will remove and reinstall Shaka Packager

# Shaka Packager with LL-DASH and ARM support
export SHAKA_PACKAGER_SOURCE="CaitlinOCallaghan"
export SHAKA_PACKAGER_COMMIT="a03b52894bccc149718a37a0a53d5b6e142cebc0"
export GYP_DEFINES="clang=0 use_allocator=none"

export PATH="$PATH:$PWD/depot_tools"
rm -rf shaka-packager
mkdir shaka-packager
cd shaka-packager
# grab the fork that contains ULL work
gclient config "https://github.com/$SHAKA_PACKAGER_SOURCE/shaka-packager.git" --name=src --unmanaged
# checkout the LL-DASH and ARM support branch
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
