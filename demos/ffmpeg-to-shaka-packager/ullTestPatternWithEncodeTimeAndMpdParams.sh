#!/bin/bash

PORT=8080
# create a unique directory
# OUTPUT_DIR=$(date '+%m-%d-%y-%T')
OUTPUT_DIR='ldash/1234'
OUTPUT_SEG_NAME='test_pattern_live_ull_video'

export UTILS_DIR="${PWD}/../utils"

[ -e pipe0 ] && rm pipe0
mkfifo pipe0

# encode with FFMPEG
X264_ENC='libx264 -tune zerolatency -profile:v baseline -preset ultrafast -bf 0 -refs 1 -sc_threshold 0'

ffmpeg \
    -hide_banner \
    -re \
    -f lavfi \
    -i "testsrc2=size=640x360:rate=60" \
    -pix_fmt yuv420p \
    -map 0:v \
    -c:v ${X264_ENC} \
    -g 300 \
    -keyint_min 300 \
    -b:v 4000k \
    -vf "drawtext=fontfile=${UTILS_DIR}/OpenSans-Bold.ttf:box=1:fontcolor=black:boxcolor=white:fontsize=33':x=14:y=150:textfile=${UTILS_DIR}/text.txt" \
    -f mpegts \
    pipe: > pipe0 &

# package as LL-DASH
packager \
   --io_block_size 65536 \
   --nogenerate_sidx_in_media_segments \
   in=pipe0,stream=video,init_segment='http://127.0.0.1:8080/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_init.m4s',segment_template='http://127.0.0.1:8080/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_$Number%05d$.m4s' \
   --segment_duration 5 \
   --minimum_update_period 500 \
   --suggested_presentation_delay 5.0 \
   --time_shift_buffer_depth 25.0 \
   --min_buffer_time 10.0 \
   --allow_approximate_segment_timeline=true \
   --is_low_latency_dash=true \
   --utc_timings "urn:mpeg:dash:utc:http-xsdate:2014"="https://time.akamai.com/?iso" \
   --mpd_output "http://127.0.0.1:8080/${OUTPUT_DIR}/manifest.mpd" \
    >& log.log
   
rm pipe0
