#!/bin/bash

export PORT=8080
export AWS_REGION='us-west-2'
export BUCKET_NAME='shaka_ull'
export CLOUD_STORAGE='mediastore' # Please select 'mediastore' or 's3'

export LAUNCH_SERVER_DIR=$PWD
export SHIM_DIR='../../s3-upload-proxy'

echo "Launching ${CLOUD_STORAGE} proxy for '${BUCKET_NAME}' on port ${PORT}"

export UPLOAD_DRIVER=${CLOUD_STORAGE} BUCKET_NAME=${BUCKET_NAME} AWS_REGION=${AWS_REGION} HTTP_PORT=${PORT} MEDIASTORE_CHUNKED_TRANSFER=true 
cd ${SHIM_DIR}
go build -o s3-upload-proxy
cd ${LAUNCH_SERVER_DIR}
./${SHIM_DIR}/s3-upload-proxy
