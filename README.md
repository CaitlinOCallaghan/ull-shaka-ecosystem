# ull-shaka-ecosystem

## Installation

NOTE: This tutorial is designed for Ubuntu 20.04.

To set up your environment, clone this repo, cd into the main directory, and run the build script. This script will install all of the needed dependencies.

```console
foo@bar:~$ git clone https://github.com/CaitlinOCallaghan/ull-shaka-ecosystem.git
foo@bar:~$ cd ull-shaka-ecosystem
foo@bar:~/ull-shaka-ecosystem$ ./buildUbuntu.sh
```

After the installation, download the provided test content.
```console
foo@bar:~/ull-shaka-ecosystem$ cd test-content
foo@bar:~/test-content$ ./downloadTestContent.sh
```

With the test content downloaded, you may now run the included demos. This will help verify that your environment is properly setup. For example, run:
```console
foo@bar:~/ull-shaka-ecosystem$ cd demos/live-shaka-streamer
foo@bar:~/live-shaka-streamer$ ./live.sh
```
