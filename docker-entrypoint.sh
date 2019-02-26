#!/bin/bash


if [ -z $SYSDIG_SECURE_TOKEN ]; then
  echo "Missing \$SYSDIG_SECURE_TOKEN env variable, aborting"
  exit 1
fi

if [ -z $IMAGE_TO_SCAN ]; then
  echo "Missing \$IMAGE_TO_SCAN env variable, aborting"
  exit 1
fi

export ANCHORE_CLI_USER=${SYSDIG_SECURE_TOKEN}
if [ -z $TIMEOUT ]; then
  echo "env var \$TIMEOUT not defined, defaulting to 10 minutes"
  export TIMEOUT=600
fi
export ANCHORE_CLI_PASS=""

echo "Adding image ${IMAGE_TO_SCAN} to Anchore engine at ${ANCHORE_CLI_URL}"
IMAGE_DIGEST=`anchore-cli image add ${IMAGE_TO_SCAN} | grep "Image Digest" | awk '{print $3}'`
if [ -z $IMAGE_DIGEST ]; then
  echo "Backend cannot pull the requested image, wrong credentials or unavailable image, aborting"
  exit 1
fi
IMAGE_TAG=`echo $IMAGE_TO_SCAN | cut -d ":" -f 2`

echo "Image digest: "$IMAGE_DIGEST
echo "Waiting for analysis to complete"
result=0
user_time=0
while [ $user_time -lt $TIMEOUT ]; do
  anchore-cli image get $IMAGE_DIGEST | grep analyzed > /dev/null
  if [ $? -ne 0 ]; then
    echo -n "."
    sleep 10
    let "user_time=user_time+10"
  else
    result=1
    break
  fi
done
[ $result -ne 1 ] && echo "Scan timedout." && exit 1

echo "Analysis complete"
anchore-cli evaluate check ${IMAGE_DIGEST} --tag $IMAGE_TAG
