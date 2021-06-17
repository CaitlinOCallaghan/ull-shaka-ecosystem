#!/bin/bash

port=8080
awsRegion='us-west-2'
containerName='shaka_ull'

serverDir=$PWD
s3UploadProxyDir='../../s3-upload-proxy'

echo "Launching MediaStore Proxy for '${containerName}' on port ${port}"

export UPLOAD_DRIVER=mediastore BUCKET_NAME=${containerName} REGION_NAME=${awsRegion} HTTP_PORT=${port}
cd ${s3UploadProxyDir}
go build -o s3-upload-proxy
cd ${serverDir}
./${s3UploadProxyDir}/s3-upload-proxy
