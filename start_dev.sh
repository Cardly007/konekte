#!/bin/bash

# This script automates the setup and startup of the development environment.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting development environment ---"

# Step 1: Start Docker services (PostgreSQL and Redis)
echo "-> Starting Docker containers for database and cache..."
docker-compose -f BackEnd/docker-compose.yml up -d
echo "-> Docker containers started."

# Wait a few seconds to ensure services are fully up and running
echo "-> Waiting for services to initialize..."
sleep 5

# Step 2: Start the FastAPI application
echo "-> Starting the FastAPI server with auto-reload..."
echo "-> API will be available at http://localhost:8000"
echo "-> Press CTRL+C to stop the server."

uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --app-dir BackEnd
