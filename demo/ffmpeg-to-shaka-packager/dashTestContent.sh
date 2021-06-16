#!/bin/bash

port=8080
# create a unique directory
dir=$(date '+%m-%d-%y-%T')
vid='BigBuckBunny'

rm pipe0
mkfifo pipe0

# encode with FFMPEG
x264enc='libx264 -tune zerolatency -profile:v high -preset ultrafast -bf 0 -refs 3 -sc_threshold 0'

ffmpeg \
    -hide_banner \
    -re \
    -i "../../test-content/BBB.mp4" \
    -pix_fmt yuv420p \
    -map 0:v \
    -c:v ${x264enc} \
    -g 150 \
    -keyint_min 150 \
    -b:v 4000k \
    -f mpegts \
    pipe: > pipe0 &

# package as DASH
packager \
   --io_block_size 65536 \
   in=pipe0,stream=video,init_segment='http://0.0.0.0:8080/'${dir}'/'${vid}'_live_video_init.m4s',segment_template='http://0.0.0.0:'${port}'/'${dir}'/'${vid}'_live_video_$Number$.m4s' \
   --segment_duration 5 \
   --mpd_output "http://0.0.0.0:${port}/${dir}/manifest.mpd"

rm pipe0
