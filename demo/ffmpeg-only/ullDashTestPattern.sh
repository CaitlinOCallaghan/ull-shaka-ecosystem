#!/bin/bash

port=8080
# create a unique directory
dir=$(date '+%m-%d-%y-%T')
vid='TestPattern'

# Encoding settings for x264 (CPU based encoder)

x264enc='libx264 -tune zerolatency -profile:v high -preset veryfast -bf 0 -refs 3 -sc_threshold 0'

ffmpeg \
    -hide_banner \
    -re \
    -f lavfi \
    -i "testsrc2=size=640x360:rate=30" \
    -pix_fmt yuv420p \
    -map 0:v \
    -c:v ${x264enc} \
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
    -media_seg_name 'chunk-stream-$RepresentationID$-$Number%05d$.m4s' \
    -init_seg_name 'init-stream1-$RepresentationID$.m4s' \
    -window_size 5  \
    -extra_window_size 10 \
    -remove_at_exit 1 \
    -adaptation_sets "id=0,streams=v id=1,streams=a" \
    -f dash \
    http://0.0.0.0:${port}/${dir}/manifest.mpd

