#!/bin/bash

# Generate a test pattern and burn the encode time into each frame

PORT=8080
IP_ADDRESS='127.0.0.1'
# create a unique directory
# OUTPUT_DIR=$(date '+%m-%d-%y-%T')
OUTPUT_DIR='encryption/n'
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
   in=pipe0,stream=video,init_segment='http://'${IP_ADDRESS}':'${PORT}'/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_init.m4s',segment_template='http://'${IP_ADDRESS}':'${PORT}'/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_$Number%05d$.m4s',drm_label=SD \
   --enable_raw_key_encryption \
   --keys label=AUDIO:key_id=f3c5e0361e6654b28f8049c778b23946:key=a4631a153a443df9eed0593043db7519:iv=11223344556677889900112233445566,label=SD:key_id=abba271e8bcf552bbd2e86a434a9a5d9:key=69eaa802a6763af979e8d1940fb88392:iv=22334455667788990011223344556677,label=HD:key_id=6d76f25cb17f5e16b8eaef6bbf582d8e:key=cb541084c99731aef4fff74500c12ead:iv=33445566778899001122334455667788 \
   --segment_duration 5 \
   --low_latency_dash_mode=true \
   --utc_timings "urn:mpeg:dash:utc:http-xsdate:2014"="https://time.akamai.com/?iso" \
   --mpd_output "http://${IP_ADDRESS}:${PORT}/${OUTPUT_DIR}/manifest.mpd" \
    >& log.log
   
rm pipe0
