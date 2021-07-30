#!/bin/bash

PORT=8080
# create a unique directory
# OUTPUT_DIR=$(date '+%m-%d-%y-%T')
OUTPUT_DIR='ldash/1234'
OUTPUT_SEG_NAME='test_pattern_live_video'

[ -e pipe0 ] && rm pipe0
mkfifo pipe0

# encode with FFMPEG
X264_ENC='libx264 -tune zerolatency -profile:v high -preset superfast -bf 0 -refs 1 -sc_threshold 0'

ffmpeg \
    -hide_banner \
    -re \
    -f lavfi \
    -i "testsrc2=size=1920x1080:rate=30" \
    -pix_fmt yuv420p \
    -map 0:v \
    -c:v ${X264_ENC} \
    -g 150 \
    -keyint_min 150 \
    -b:v 4000k \
    -vf "fps=30" \
    -f mpegts \
    pipe: > pipe0 &

# package as DASH
/home/cocallaghan/Workspace/ull-shaka-ecosystem/shaka-packager/src/out/Release/packager \
   --v=2 \
   --io_block_size 65536 \
   --nogenerate_sidx_in_media_segments \
   in=pipe0,stream=video,init_segment='http://127.0.0.1:8080/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_init.m4s',segment_template='http://127.0.0.1:8080/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_$Number$.m4s' \
   --segment_duration 5 \
   --minimum_update_period 500 \
   --suggested_presentation_delay 5.0 \
   --time_shift_buffer_depth 25.0 \
   --min_buffer_time 10.0 \
   --allow_approximate_segment_timeline=true \
   --is_low_latency_dash=true \
   --mpd_output "http://127.0.0.1:8080/${OUTPUT_DIR}/manifest.mpd" \
    >& log.log
   
rm pipe0
