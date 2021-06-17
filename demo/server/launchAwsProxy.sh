#!/bin/bash

port=8080
awsRegion='us-west-2'
bucketName='shaka_ull'
cloudStorage='mediastore' # Please select 'mediastore' or 's3'

serverDir=$PWD
s3UploadProxyDir='../../s3-upload-proxy'

echo "Launching ${cloudStorage} proxy for '${bucketName}' on port ${port}"

export UPLOAD_DRIVER=${cloudStorage} BUCKET_NAME=${bucketName} REGION_NAME=${awsRegion} HTTP_PORT=${port}
cd ${s3UploadProxyDir}
go build -o s3-upload-proxy
cd ${serverDir}
./${s3UploadProxyDir}/s3-upload-proxy
