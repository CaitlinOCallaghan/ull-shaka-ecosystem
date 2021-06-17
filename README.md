# ull-shaka-ecosystem

## Installation

NOTE: This tutorial is designed for Ubuntu 20.04.

## General

To set up your environment, clone this repo, cd into the main directory, and run the build script. This script will install all of the needed dependencies.

```console
foo@bar:~$ git clone https://github.com/CaitlinOCallaghan/ull-shaka-ecosystem.git
foo@bar:~$ cd ull-shaka-ecosystem
foo@bar:~/ull-shaka-ecosystem$ ./buildUbuntu.sh
```

After the installation, download the provided test content.
```console
foo@bar:~/ull-shaka-ecosystem$ cd test-content
foo@bar:~/test-content$ ./downloadTestContent.sh
```

With the test content downloaded, you may now run the included demos. This will help verify that your environment is properly setup. For example, run:
```console
foo@bar:~/ull-shaka-ecosystem$ cd demos/live-shaka-streamer
foo@bar:~/live-shaka-streamer$ ./live.sh
```

## AWS

### Command Line
After the general installation, configure your AWS credentials with awscli. This step is critical for accessing your S3 buckets and MediaStore containers. Follow the command line prompts to enter your Access Key ID and Secret Access Key. For more information and instructions on where to find your AWS keys, you can visit AWS documentation [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html). 

```console
foo@bar:~$ aws configure
```

To ensure that your credentials have been added, checkout your aws directory and peek into the credentials file. 

```console
foo@bar:~$ cd ~/.aws
foo@bar:~/.aws$ cat credentials
[default]
aws_access_key_id={YOUR KEY ID}
aws_secret_access_key={YOUR KEY}
foo@bar:~/.aws$
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
foo@bar:~/ull-shaka-ecosystem/demo/server$ ./launchAwsProxy.sh
```

You are now ready to stream to AWS via the listening HTTP proxy!


Through the AWS web console, you can access links for the video manifests and play them out via Shaka Player, Dash.js, QuickTime player, or VLC. 
