#!/bin/bash

# Script to run with docker-compose

set -e

echo "Starting MuchToDo application with docker-compose..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found!"
    echo "Please create a .env file with required environment variables."
    exit 1
fi

# Stop any running containers
echo "Stopping any existing containers..."
docker-compose down -v

# Start services
echo "Starting services..."
docker-compose up -d

# Wait for services to be healthy
echo "Waiting for services to be ready..."
sleep 10

# Check service status
docker-compose ps

echo ""
echo "Services started successfully!"
echo "API available at: http://localhost:8080"
echo "Health check: http://localhost:8080/health"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop: docker-compose down -v"