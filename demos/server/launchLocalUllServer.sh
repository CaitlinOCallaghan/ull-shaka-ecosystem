#!/bin/bash

CURR_DIR=$PWD

# launch the server locally on port 8080
cd ../../low-latency-preview
./launchServer.sh
cd ${CURR_DIR}
