#!/bin/bash

# Script to build Docker images

set -e

echo "Building MuchToDo Docker image..."

# Build the image
docker build -t ifeolaitan/muchtodo:v1 -f Dockerfile .

echo "Docker image built successfully: ifeolaitan/muchtodo:v1"

# Optional: Push to Docker Hub
# echo "Pushing to Docker Hub..."
# docker push ifeolaitan/muchtodo:v1

echo "Build complete!"