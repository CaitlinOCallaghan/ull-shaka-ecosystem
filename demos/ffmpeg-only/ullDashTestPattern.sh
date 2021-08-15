#!/bin/bash

PORT=8080
IP_ADDRESS='127.0.0.1'
# create a unique directory
OUTPUT_DIR=$(date '+%m-%d-%y-%T')
OUTPUT_SEG_NAME='test_pattern_live_ull_video'

# Encoding settings for x264 (CPU based encoder)
X264_ENC='libx264 -tune zerolatency -profile:v high -preset baseline -bf 0 -refs 1 -sc_threshold 0'

ffmpeg \
    -hide_banner \
    -re \
    -f lavfi \
    -i "testsrc2=size=640x360:rate=30" \
    -pix_fmt yuv420p \
    -map 0:v \
    -c:v ${X264_ENC} \
    -b:v 4000k \
    -g 150 \
    -keyint_min 150 \
    -method PUT \
    -seg_duration 5 \
    -streaming 1 \
    -http_persistent 1 \
    -utc_timing_url "https://time.akamai.com/?iso" \
    -index_correction 1 \
    -use_timeline 0 \
    -media_seg_name ''${OUTPUT_SEG_NAME}'_$Number%05d$.m4s' \
    -init_seg_name ''${OUTPUT_SEG_NAME}'_init.m4s' \
    -window_size 5  \
    -extra_window_size 10 \
    -remove_at_exit 1 \
    -adaptation_sets "id=0,streams=v id=1,streams=a" \
    -f dash \
    http://${IP_ADDRESS}:${PORT}/${OUTPUT_DIR}/manifest.mpd

