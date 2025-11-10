#!/bin/bash

# This script provides a complete, one-stop solution for starting the development environment.
# It manages Docker containers and the application server, ensuring a clean and reliable startup.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting All Services for Development ---"

# Check if .env file exists
if [ ! -f "BackEnd/.env" ]; then
    echo "-> .env file not found. Creating one from the example..."
    cp BackEnd/.env.example BackEnd/.env
    echo "-> .env file created. Please review it and fill in any necessary secrets."
fi

# Step 1: Stop any running Docker containers from a previous session
echo "-> Stopping and removing any old Docker containers..."
docker-compose -f BackEnd/docker-compose.yml down

# Step 2: Start new Docker containers for PostgreSQL and Redis
echo "-> Starting fresh Docker containers for database and cache..."
docker-compose -f BackEnd/docker-compose.yml up -d
echo "-> Docker containers are up and running."

# Step 3: Wait for services to be fully initialized
echo "-> Waiting 10 seconds for services to initialize..."
sleep 10

# Step 4: Start the FastAPI application server
echo "-> Starting the FastAPI server with auto-reload..."
echo "-> API will be available at http://localhost:8000"
echo "-> Press CTRL+C to stop the server."

uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --app-dir BackEnd
