#!/bin/bash

IMAGE=${IMAGE:-quay.io/mvala/oidc-example-app:latest}

set -x

docker build -t ${IMAGE} .
docker push ${IMAGE}
