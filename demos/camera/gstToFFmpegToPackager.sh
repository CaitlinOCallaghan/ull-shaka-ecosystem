#!/bin/bash

export PORT=8080
export OUTPUT_DIR='ldash/1234'
export OUTPUT_SEG_NAME='camera_live_video'

[ -e pipe0 ] && rm pipe0
mkfifo pipe0

[ -e pipe1 ] && rm pipe1
mkfifo pipe1

# encode with FFMPEG
export X264_ENC='libx264 -tune zerolatency -profile:v baseline -preset ultrafast -bf 0 -refs 1 -sc_threshold 0'

# set display for camera
export DISPLAY=:0

gst-launch-1.0 \
   -e \
   nvarguscamerasrc sensor-id=0 ! \
   "video/x-raw(memory:NVMM),width=1920,height=1080,framerate=60/1,format=NV12" ! \
   nvvidconv ! \
  "video/x-raw, width=1920, height=1080, format=I420, framerate=60/1" ! \
   matroskamux ! \
   filesink location=pipe0 &

ffmpeg \
    -hide_banner \
    -re \
    -i pipe0 \
    -map 0:v \
    -c:v ${X264_ENC} \
    -g 300 \
    -keyint_min 300 \
    -b:v 4000k \
    -f mpegts \
    pipe: > pipe1 &

# package as LL-DASH
packager \
   --v=0 \
   --io_block_size 65536 \
   --nogenerate_sidx_in_media_segments \
   in=pipe1,stream=video,init_segment='http://127.0.0.1:8080/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_init.m4s',segment_template='http://127.0.0.1:8080/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_$Number%05d$.m4s' \
   --segment_duration 5 \
   --low_latency_dash_mode=true \
   --utc_timings "urn:mpeg:dash:utc:http-xsdate:2014"="https://time.akamai.com/?iso" \
   --mpd_output "http://127.0.0.1:8080/${OUTPUT_DIR}/manifest.mpd" \
    >& log.log
