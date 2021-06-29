# ull-shaka-ecosystem

## Installation

NOTE: This tutorial is designed for Ubuntu 20.04.

To set up your environment, clone this repo, cd into the main directory, and run the build script. This script will install all of the needed dependencies.

```console
git clone https://github.com/CaitlinOCallaghan/ull-shaka-ecosystem.git
cd ull-shaka-ecosystem
./buildUbuntu.sh
```

You may now run a test stream with a test pattern by running:

```console
cd demo/live-shaka-streamer
./liveTestPattern.sh
```
Your manifest will be available at http://127.0.0.1/testpattern/dash.mpd

You may view this in ffplay, shaka player, dash.js, exoplayer, etc.

For example you could run:
```console
ffplay http://127.0.0.1/testpattern/dash.mpd
```

You may also use test video content if you wish. 

To download test content you may run:

```console
cd test-content
./downloadTestContent.sh
cd ..
```

You may now run a test stream with the provided test content by running:

```console
cd demo/live-shaka-streamer
./liveLoopedFile.sh
```
Your manifest will be available at http://127.0.0.1/livelooped/dash.mpd

You may view this in ffplay, shaka player, dash.js, exoplayer, etc.

For example you could run:
```console
ffplay http://127.0.0.1/livelooped/dash.mpd
```
