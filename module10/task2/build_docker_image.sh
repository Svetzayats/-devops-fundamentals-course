#!/bin/bash

# Define the name of the Docker image and the Docker registry
IMAGE_NAME="nestjs-api"
REGISTRY="svetzayats/training"

# Check if at least one tag is passed as an argument
if [ $# -eq 0 ]
  then
    echo "Please specify tag name."
    exit 1
fi

# Add the tags to the Docker image
for tag in "$@"; do
  docker tag $IMAGE_NAME $REGISTRY:$tag
done

# Push the Docker image to the registry
docker push $REGISTRY:$tag
