#!/bin/bash -
source .env

test $SENTRY_IMAGE
test $PUBLIC_REPOSITORY

docker build -t ${PUBLIC_REPOSITORY}/$SENTRY_IMAGE \
	--build-arg SENTRY_IMAGE=$SENTRY_IMAGE .
docker push ${PUBLIC_REPOSITORY}/$SENTRY_IMAGE
