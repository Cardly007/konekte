#!/bin/bash

# This script starts the FastAPI server for development.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting FastAPI Development Server ---"

# Check if the .env file exists
if [ ! -f "BackEnd/.env" ]; then
    echo "ERROR: .env file not found!"
    echo "Please create it by copying BackEnd/.env.example and configuring it for your environment."
    exit 1
fi

echo "-> Make sure your database and Redis services are running."
echo "-> Starting the FastAPI server with auto-reload..."
echo "-> API will be available at http://localhost:8000"
echo "-> Press CTRL+C to stop the server."

uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --app-dir BackEnd
