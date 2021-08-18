#!/bin/bash

# This script will remove and reinstall Shaka Packager
# The version of Shaka Packager being installed is compatible with x86_64 and aarch64

# Shaka Packager with LL-DASH
export SHAKA_PACKAGER_SOURCE="CaitlinOCallaghan"
export SHAKA_PACKAGER_COMMIT="5eda83ee491acb992de6f138ecf621370717ca73"

export PATH="$PATH:$PWD/depot_tools"
rm -rf shaka-packager
mkdir shaka-packager
cd shaka-packager
# grab the fork that contains ULL work
gclient config "https://github.com/$SHAKA_PACKAGER_SOURCE/shaka-packager.git" --name=src --unmanaged
# checkout the LL-DASH support branch
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
