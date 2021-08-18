#!/bin/bash

export PORT=8080
export OUTPUT_DIR='ldash/1234'
export OUTPUT_SEG_NAME='camera_live_video'

# set display for camera
export DISPLAY=:0

gst-launch-1.0 \
   -e \
   nvarguscamerasrc sensor-id=0 ! \
   "video/x-raw(memory:NVMM),width=1920,height=1080,framerate=60/1,format=NV12" ! \
   nvvidconv ! \
   "video/x-raw, width=1920, height=1080, format=I420, framerate=60/1" ! \
   omxh264enc ! \
   "video/x-h264,stream-format=byte-stream" ! \
   mpegtsmux ! \
   udpsink host=127.0.0.1 port=1234  &

# package as LL-DASH
packager \
   --v=0 \
   --io_block_size 65536 \
   --nogenerate_sidx_in_media_segments \
   in='udp://127.0.0.1:1234',stream=video,init_segment='http://127.0.0.1:8080/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_init.m4s',segment_template='http://127.0.0.1:8080/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_$Number%05d$.m4s' \
   --segment_duration 5 \
   --low_latency_dash_mode=true \
   --utc_timings "urn:mpeg:dash:utc:http-xsdate:2014"="https://time.akamai.com/?iso" \
   --mpd_output "http://127.0.0.1:8080/${OUTPUT_DIR}/manifest.mpd" \
    >& log.log
