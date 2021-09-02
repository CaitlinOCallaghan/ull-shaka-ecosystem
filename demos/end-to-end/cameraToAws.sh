#!/bin/bash

# Stream naming
export OUTPUT_DIR='1234' # Directory for segments
export OUTPUT_SEG_NAME='camera_ll_dash_live_video' # Segment naming scheme
export MANIFEST_NAME='manifest.mpd' # Name for LL-DASH manifest, must have .mpd extension

# s3-upload-proxy variables
export UPLOAD_DRIVER='mediastore' # Please select 'mediastore' or 's3'
export BUCKET_NAME='shaka_ull' # Specify S3 bucket or MediaStore container name
export AWS_REGION='us-west-2' # Specify the region of the S3 bucket or MediaStore container
export HTTP_PORT=8080 # Port you wish to host s3-upload-proxy on

export MEDIASTORE_CHUNKED_TRANSFER=true # DO NOT CHANGE
export IP=127.0.0.1 # DO NOT CHANGE

# Encoding parameters - change as you like
export X264_ENC='libx264 -tune zerolatency -profile:v baseline -preset ultrafast -bf 0 -refs 1 -sc_threshold 0'

# set display for camera
export DISPLAY=:0

# Create log folder
[ -e logs ] && rm -rf logs
mkdir logs

# Create pipe for gst --> ffmpeg
[ -e pipe0 ] && rm pipe0
mkfifo pipe0

# Create pipe for ffmpeg --> packager
[ -e pipe1 ] && rm pipe1
mkfifo pipe1

# Set up cleanup process
trap_ctrlc() {
    echo -e "\nStream has ended. Cleanup taking place."

    pkill s3-upload-proxy
    pkill ffmpeg
    pkill packager

    rm pipe0
    rm pipe1

    echo "All processes have been killed ☠"
}

trap trap_ctrlc INT

echo "Launching s3-upload-proxy! Please wait a few seconds"

# Launch the shim to MediaStore
s3-upload-proxy 2>logs/server.log &

# Give server time to get up and running
while ! pgrep -x "s3-upload-proxy" >/dev/null
do sleep 1
done

echo "Server is up! Go to the ${BUCKET_NAME} AWS console to grab your stream at ${OUTPUT_DIR}/${MANIFEST_NAME}"

# gst-launch-1.0 \
#    -e \
#    nvarguscamerasrc sensor-id=0 ! \
#    "video/x-raw(memory:NVMM),width=1920,height=1080,framerate=60/1,format=NV12" ! \
#    nvvidconv ! \
#   "video/x-raw, width=1920, height=1080, format=I420, framerate=60/1" ! \
#    matroskamux ! \
#    filesink location=pipe0 &

# # Encode the camera stream with FFMPEG and send to pipe
# ffmpeg \
#     -hide_banner \
#     -re \
#     -i pipe0 \
#     -map 0:v \
#     -c:v ${X264_ENC} \
#     -g 300 \
#     -keyint_min 300 \
#     -b:v 4000k \
#     -f mpegts \
#     pipe: > pipe1 \
#     2>logs/ffmpeg.log &

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
   in=pipe1,stream=video,init_segment='http://'${IP}':'${HTTP_PORT}'/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_init.m4s',segment_template='http://'${IP}':'${HTTP_PORT}'/'${OUTPUT_DIR}'/'${OUTPUT_SEG_NAME}'_$Number%05d$.m4s' \
   --segment_duration 5 \
   --enable_fixed_key_encryption \
   --enable_fixed_key_decryption \
   --keys label=:key_id=7fd155d651b025c99f39ba1680c359df:key=d967fc60f52e83f311e6b6808f76bf46 \
   --low_latency_dash_mode=true \
   --utc_timings "urn:mpeg:dash:utc:http-xsdate:2014"="https://time.akamai.com/?iso" \
   --mpd_output "http://${IP}:${HTTP_PORT}/${OUTPUT_DIR}/${MANIFEST_NAME}" \
    2> logs/packager.log & 

# Wait for all background processes to terminate or Control-C
wait
