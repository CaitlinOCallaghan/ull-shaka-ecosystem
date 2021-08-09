#!/bin/bash

# Set up variables
export LOW_LATENCY_PREVIEW_DIR="${PWD}/../../low-latency-preview"
export UTILS_DIR="${PWD}/../utils"

export PORT=8080
export IP=127.0.0.1
export OUTPUT_DIR='1234'
export OUTPUT_SEG_NAME='usb_camera_pattern_live_video'

export X264_ENC='libx264 -tune zerolatency -profile:v baseline -preset ultrafast -bf 0 -refs 1 -sc_threshold 0'

export SERVER_UPLOAD_DIR='ldash'
export SERVER_PLAYOUT_DIR='ldashplay'

# Create log folder
[ -e logs ] && rm -rf logs
mkdir logs

# Create pipe for ffmpeg --> packager
[ -e pipe1 ] && rm pipe1
mkfifo pipe1

# Set up cleanup process
trap_ctrlc() {
    echo -e "\nStream has ended. Cleanup taking place."

    pkill main
    pkill ffmpeg
    pkill packager

    rm pipe0

    echo "All processes have been killed ☠"
}

trap trap_ctrlc INT

echo "Launching local server! Please wait a few seconds"

# Launch the local server on port 8080
go run ${LOW_LATENCY_PREVIEW_DIR}/main.go "${LOW_LATENCY_PREVIEW_DIR}/www" 2>logs/server.log &

# Give server time to get up and running
while ! pgrep -x "main" >/dev/null
do sleep 1
done

echo "Server is up! Checkout the stream at: http://${IP}:${PORT}/${SERVER_PLAYOUT_DIR}/${OUTPUT_DIR}/manifest.mpd"

# Encode the USB cam output with FFMPEG and send to pipe
ffmpeg \
    -hide_banner \
    -re \
    -f v4l2 \
    -framerate 60 \
    -video_size 1920x1080 \
    -i /dev/video0 \
    -c:v ${X264_ENC} \
    -pix_fmt yuv420p \
    -crf 23 \
    -movflags faststart \
    -f mpegts \
    pipe: > pipe1 \
    2>logs/ffmpeg.log &

# Package test pattern as LL-DASH
packager \
   --v=0 \
   --io_block_size 65536 \
   --nogenerate_sidx_in_media_segments \
   in=pipe1,stream=video,init_segment='http://'${IP}':'${PORT}'/'${SERVER_UPLOAD_DIR}'/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_init.m4s',segment_template='http://'${IP}':'${PORT}'/'${SERVER_UPLOAD_DIR}'/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_$Number%05d$.m4s' \
   --segment_duration 5 \
   --is_low_latency_dash=true \
   --utc_timings "urn:mpeg:dash:utc:http-xsdate:2014"="https://time.akamai.com/?iso" \
   --mpd_output "http://${IP}:${PORT}/${SERVER_UPLOAD_DIR}/${OUTPUT_DIR}/manifest.mpd" \
    2> logs/packager.log & 

# Wait for all background processes to terminate or Control-C
wait
