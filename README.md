# ull-shaka-ecosystem

## Installation

This tutorial is designed for Ubuntu 20.04.
The following scripts will install dependencies in the OS. 
Please use a virtual machine in VMware, UTM, virtualbox, etc to test.

You can download Ubuntu 20.04 for free from here (protip: BitTorrent is often faster!):

https://ubuntu.com/download/desktop

For Macs, you can download UTM to run virtual machines on your Mac, x86 or ARM (this repo is not yet ARM tested), for free here:

https://getutm.app

Install UTM, then open it, and create a new virtual machine.

Import the Ubuntu ISO into UTM as a virtual drive, and, make a 10 gig virtual hard drive to install Ubuntu to. (Protip: During the instalation process select ZFS so you can use snapshots if you want to roll your envrionment back.)

When the instalation is done, shut down the VM, and unmount the virtual drive that is the ISO. 

Now boot the VM and you should be ready to go in Ubuntu 20.04.

To set up your environment, open a terminal and clone this repo, cd into the main directory, and run the build script. This script will install all of the needed dependencies.

```console
git clone https://github.com/CaitlinOCallaghan/ull-shaka-ecosystem.git
cd ull-shaka-ecosystem
./buildUbuntu2004.sh
```

You may now run a test stream with a test pattern by running:

```console
cd ~/ull-shaka-ecosystem/demos/live-shaka-streamer
./liveTestPattern.sh
```
Your manifest will be available at http://127.0.0.1/testpattern/dash.mpd

You may view this in ffplay, shaka player, dash.js, exoplayer, etc.

For example you could run:
```console
ffplay http://127.0.0.1/testpattern/dash.mpd
```

You may also use test video content if you wish. 

To download test content you may run:

```console
cd ~/ull-shaka-ecosystem/test-content
./downloadTestContent.sh
```

You may now run a test stream with the provided test content by running:

```console
cd ~/ull-shaka-ecosystem/demos/live-shaka-streamer
./liveLoopedFile.sh
```
Your manifest will be available at http://127.0.0.1/livelooped/dash.mpd

You may view this in ffplay, shaka player, dash.js, exoplayer, etc.

For example you could run:
```console
ffplay http://127.0.0.1/livelooped/dash.mpd
```

While this is a self contained demo, if you would like to use AWS as the server side componet of this project, please read on, otherwise you can stop here.

## AWS

### Command Line
After the general installation, configure your AWS credentials with awscli. This step is critical for accessing your S3 buckets and MediaStore containers. Follow the command line prompts to enter your Access Key ID and Secret Access Key. For more information and instructions on where to find your AWS keys, you can visit AWS documentation [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html). 

```console
aws configure
```

To ensure that your credentials have been added, checkout your aws directory and peek into the credentials file. 

```console
cat ~/.aws/credentials
```
It should look like:

```console
[default]
aws_access_key_id={YOUR KEY ID}
aws_secret_access_key={YOUR KEY}
```

### Cloud
Before streaming to AWS, HTTP authorization must be granted in the bucket and container policies. Make sure that the "Resource" is set to your unique bucket or container arn which will include your region. Under "Principal", set the "AWS" value to include your account number.  

For S3 Buckets, ensure that the policy is: 

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::44444444444:root"
            },
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": "arn:aws:s3:::bucket-name/*"
        }
    ]
}
```

For MediaStore Containers, set the container policy to: 

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "MediaStoreFullAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::44444444444:root"
      },
      "Action": "mediastore:*",
      "Resource": "arn:aws:mediastore:us-west-2:555555555555:container/container-name/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "true"
        }
      }
    },
    {
      "Sid": "PublicReadOverHttps",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "mediastore:GetObject",
        "mediastore:DescribeObject"
      ],
      "Resource": "arn:aws:mediastore:us-west-2:555555555555:container/container-name/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "true"
        }
      }
    }
  ]
}
```

With AWS set up, it's time to stream the video! 

Start by launching the proxy on S3 or MediaStore. Ensure that you edit the script to point to your specific bucket or container.

```console
cd ~/ull-shaka-ecosystem/demo/server 
./launchAwsProxy.sh
```

You are now ready to stream to AWS via the listening HTTP proxy!


Through the AWS web console, you can access links for the video manifests and play them out via Shaka Player, Dash.js, QuickTime player, or VLC. 

### AWS Protips

S3 and Mediastore are both origin hosting services.
S3 is more affordable.
Mediastore is higher performance for live and low latency live video.

The S3 web console allows users to easily purge the entire bucket with once click. However, MediaStore does not. To empty a MediaStore container through the web console, you must delete files page by page, and you cannot delete a directory until it is empty. If you wish to purge your MediaStore container in one go, please use the following script.

```console
cd ~/ull-shaka-ecosystem/demo/server
./emptyMediaStoreContainer.sh
```

### Running under Docker

ull-shaka-ecosystem can also run from Docker container, run ```./buildDocker.sh``` this will result in a bash prompt to run the above

To attach to running shaka_builder get the container id and exec a new bash shell...

```docker ps```

```
CONTAINER ID   IMAGE           COMMAND               CREATED          STATUS          PORTS                                   NAMES
b0e63e96ec3a   shaka_builder   "bash -c /bin/bash"   21 seconds ago   Up 20 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp   strange_bose
```

```docker exec -i -t b0e63e96ec3a /bin/bash```
