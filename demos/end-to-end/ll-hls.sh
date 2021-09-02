#!/bin/bash

# Set up variables
export LOW_LATENCY_PREVIEW_DIR="${PWD}/../../low-latency-preview"
export UTILS_DIR="${PWD}/../utils"

export PORT=8080
export IP_ADDRESS='127.0.0.1'
export OUTPUT_DIR='ll_HLS'
export OUTPUT_SEG_NAME='test_pattern_live_video'
export X264_ENC='libx264 -tune zerolatency -profile:v baseline -preset ultrafast -bf 0 -refs 1 -sc_threshold 0'

export SERVER_UPLOAD_DIR='ldash'
export SERVER_PLAYOUT_DIR='ldashplay'

# Create log folder
[ -e logs ] && rm -rf logs
mkdir logs

# Create pipe
[ -e pipe0 ] && rm pipe0
mkfifo pipe0

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

echo "Server is up! Checkout the stream at: http://${IP_ADDRESS}:${PORT}/${SERVER_PLAYOUT_DIR}/${OUTPUT_DIR}/manifest.mpd"

# Generate the test pattern with FFMPEG and send to pipe
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
    -vf "drawtext=fontfile=${UTILS_DIR}/OpenSans-Bold.ttf:box=1:fontcolor=black:boxcolor=white:fontsize=33':x=14:y=150:textfile=${UTILS_DIR}/text.txt'" \
    -f mpegts \
    pipe: > pipe0 \
    2>logs/ffmpeg.log &

# Package test pattern as LL-DASH
/home/cocallaghan/Workspace/ull-shaka-ecosystem/shaka-packager/src/out/Release/packager \
   --v=0 \
   --io_block_size 65536 \
   --nogenerate_sidx_in_media_segments \
   in=pipe0,stream=video,init_segment='http://'${IP_ADDRESS}':'${PORT}'/'${SERVER_UPLOAD_DIR}'/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_init.m4s',segment_template='http://'${IP_ADDRESS}':'${PORT}'/'${SERVER_UPLOAD_DIR}'/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_$Number%05d$.m4s' \
   --segment_duration 5 \
   --utc_timings "urn:mpeg:dash:utc:http-xsdate:2014"="https://time.akamai.com/?iso" \
   --low_latency_dash_mode=true \
   --hls_playlist_type LIVE \
   --hls_master_playlist_output "http://${IP_ADDRESS}:${PORT}/${SERVER_UPLOAD_DIR}/${OUTPUT_DIR}/playlist.m3u8" \
    2> logs/packager.log & 

# Wait for all background processes to terminate or Control-C
wait


#    --mpd_output "http://${IP_ADDRESS}:${PORT}/${SERVER_UPLOAD_DIR}/${OUTPUT_DIR}/manifest.mpd" \
