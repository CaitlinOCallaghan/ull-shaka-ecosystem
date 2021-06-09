#!/bin/bash

# Download sample content for testing and demos

# Big Buck Bunny
curl -o BBB.mp4 http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4\

ffmpeg -i BBB.mp4 -ss 0 -t 60 BBB_1min.mp4
ffmpeg -i BBB.mp4 -ss 0 -t 30 BBB_30sec.mp4
