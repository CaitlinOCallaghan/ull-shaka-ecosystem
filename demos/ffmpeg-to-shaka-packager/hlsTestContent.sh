#!/bin/bash

PORT=8080
# create a unique directory
OUTPUT_DIR=$(date '+%m-%d-%y-%T')
OUTPUT_SEG_NAME='big_buck_bunny_live_video'

[ -e pipe0 ] && rm pipe0
mkfifo pipe0

# encode with FFMPEG
X264_ENC='libx264 -tune zerolatency -profile:v high -preset ultrafast -bf 0 -refs 3 -sc_threshold 0'

ffmpeg \
    -hide_banner \
    -re \
    -i "../../test-content/BBB.mp4" \
    -pix_fmt yuv420p \
    -map 0:v \
    -c:v ${X264_ENC} \
    -g 150 \
    -keyint_min 150 \
    -b:v 4000k \
    -f mpegts \
    pipe: > pipe0 &

# package as HLS
packager \
   --io_block_size 65536 \
   in=pipe0,stream=video,segment_template='http://0.0.0.0:'${PORT}'/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_$Number$.ts' \
   --segment_duration 5 \
   --hls_playlist_type LIVE \
   --hls_master_playlist_output "http://0.0.0.0:${PORT}/${OUTPUT_DIR}/playlist.m3u8"

rm pipe0
