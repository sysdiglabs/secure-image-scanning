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
IMAGE_DIGEST=`anchore-cli --json image add ${IMAGE_TO_SCAN} | jq -r ".[].imageDigest"`
if [ -z $IMAGE_DIGEST ]; then
  echo "Backend cannot pull the requested image, wrong credentials or unavailable image, aborting"
  exit 1
fi
IMAGE_TAG=`echo $IMAGE_TO_SCAN | cut -d ":" -f 2`

echo "Image digest: "$IMAGE_DIGEST
echo "Waiting for analysis to complete"
result=0
user_time=0
retries=0
notanalyzed=1 #1 when failure, 0 when success
while [ $user_time -lt $TIMEOUT ]; do
  anchore-cli image get $IMAGE_DIGEST | grep analyzed > /dev/null
  notanalyzed=$?
  if [ $notanalyzed -ne 0 ]; then
    echo -n "."
    sleep 10
    let "user_time=user_time+10"
  else
    let "retries=retries+1"
    if [ $notanalyzed -ne 0 ] && [ $retries -lt $MAX_RETRIES ]; then
      echo -n "#"
      sleep 10
    else
      break
    fi
  fi
done
[ $notanalyzed -ne 0 ] && echo "Scan timedout." && exit 1
echo "Waiting for scan analysis report to be ready"
retries=0
user_time=0
wait=5
report=$(anchore-cli evaluate check ${IMAGE_DIGEST} --tag $IMAGE_TAG)
result=$?
while [ $result -ne 0 ] && [ $user_time -lt $TIMEOUT ]; do 
  let "retries=retries+1"
  echo -n "."
  sleep $wait
  let "user_time=user_time+wait"
  let "wait=wait+5"
  report=$(anchore-cli evaluate check ${IMAGE_DIGEST} --tag $IMAGE_TAG)
  result=$?
done
[ $retries -gt 0 ] && echo
echo "$report"
exit $result