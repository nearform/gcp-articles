#!/bin/bash
IMAGE=$1
gcloud auth configure-docker
docker build -t $IMAGE ../../app
docker push $IMAGE
