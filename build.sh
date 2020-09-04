#!/bin/bash

set -e

DOCKER_TAG=nbakaev/redis-sentinel:6.0.7

docker build -t $DOCKER_TAG .
docker push $DOCKER_TAG
