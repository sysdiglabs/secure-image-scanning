# Sysdig Secure Image Scanning

This directory contains the Dockerfile and entrypoint for
`sysdiglabs/secure-image-scanning`

This Docker image does an static scanning looking for vulnerabilities in the
image provided.

## Usage

`
docker run -e IMAGE_TO_SCAN="docker.io/library/ubuntu:latest" \
           -e SYSDIG_SECURE_TOKEN="xxXXxxXXXxxXX" \
           sysdiglabs/secure-image-scanning
`

### Environment variables used as parameters

* IMAGE_TO_SCAN: The image which is going to be scanned i.e.: docker.io/library/debian:latest
* SYSDIG_SECURE_TOKEN: The Sysdig Secure API Token.
* TIMEOUT: Timeout for the image scanning, by default is 10 minutes.
* MAX_RETRIES: Sometimes when analyzing the images, the registry takes some time for sending the image and it could lead to a `Not Found` error. So we implemented a retrying mechanism. By default it tries 3 times before giving up.

## Makefile usage

The Makefile contains 3 targets:

* `all`: Builds the image and pushes it to DockerHub
* `build`: Builds the image
* `push`: Pushes the image to DockerHub
