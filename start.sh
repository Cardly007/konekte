#!/bin/bash

# This script provides a complete, one-stop solution for starting the development environment.

set -e

echo "--- Starting All Services for Development ---"

ENV_FILE="BackEnd/.env"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "-> .env file not found. Creating one from the example..."
    cp BackEnd/.env.example "$ENV_FILE"
    echo "-> .env file created. Please review it if needed."
fi

# Step 1: Stop any running Docker containers
echo "-> Stopping and removing any old Docker containers..."
docker-compose -f BackEnd/docker-compose.yml down

# Step 2: Start new Docker containers, ensuring they use the correct .env file
echo "-> Starting fresh Docker containers for database and cache..."
docker-compose -f BackEnd/docker-compose.yml --env-file "$ENV_FILE" up -d
echo "-> Docker containers are up and running."

# Step 3: Wait for services to be fully initialized
echo "-> Waiting 10 seconds for services to initialize..."
sleep 10

# Step 4: Start the FastAPI application server
echo "-> Starting the FastAPI server with auto-reload..."
echo "-> API will be available at http://localhost:8000"
echo "-> Press CTRL+C to stop the server."

uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --app-dir BackEnd
