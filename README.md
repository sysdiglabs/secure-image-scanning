# Sysdig Secure Image Scanning

This directory contains the Dockerfile and entrypoint for
`sysdiglabs/secure-image-scanning`

This Docker image does an static scanning looking for vulnerabilities in the
image provided.

## Usage

`
docker run -e IMAGE_TO_SCAN="docker.io/library/ubuntu:latest" \
           -e ANCHORE_CLI_USER="xxXXxxXXXxxXX" \
           sysdiglabs/secure-image-scanning
`

### Parameters

* IMAGE_TO_SCAN: The image which is going to be scanned i.e.: docker.io/library/debian:latest
* ANCHORE_CLI_USER: The user used to connect to Anchore API. Can be also the Sysdig Secure API Token.
* ANCHORE_CLI_PASS: The password used to connect to Anchore API. By default is empty.
* ANCHORE_CLI_URL: The URL where Anchore server is deployed. By default is `https://secure.sysdig.com/api/scanning/v1/anchore`

## Makefile usage

The Makefile contains 3 targets:

* `all`: Builds the image and pushes it to DockerHub
* `build`: Builds the image
* `push`: Pushes the image to DockerHub
