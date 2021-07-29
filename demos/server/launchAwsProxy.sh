#!/bin/bash

PORT=8080
AWS_REGION='us-west-2'
BUCKET_NAME='shaka_ull'
CLOUD_STORAGE='mediastore' # Please select 'mediastore' or 's3'

LAUNCH_SERVER_DIR=$PWD
SHIM_DIR='../../s3-upload-proxy'

echo "Launching ${CLOUD_STORAGE} proxy for '${BUCKET_NAME}' on port ${PORT}"

export UPLOAD_DRIVER=${CLOUD_STORAGE} BUCKET_NAME=${BUCKET_NAME} REGION_NAME=${AWS_REGION} HTTP_PORT=${PORT}
cd ${SHIM_DIR}
go build -o s3-upload-proxy
cd ${LAUNCH_SERVER_DIR}
./${SHIM_DIR}/s3-upload-proxy
