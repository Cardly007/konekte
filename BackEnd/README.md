# Konekte Backend

This directory contains the Python/FastAPI backend for the Konekte application.

## Local Development Setup

This guide will walk you through setting up and running the backend for development.

### Step 1: Initial Configuration

This only needs to be done once.

1.  **Install Dependencies**
    From the project root, install all required Python packages.
    ```bash
    pip install -r BackEnd/requirements.txt
    ```
    *(Note: Re-run this command anytime you pull new changes to the project.)*

2.  **Set Up Environment Variables**
    Create your local environment file by copying the example.
    ```bash
    # From the project root, run:
    cp BackEnd/.env.example BackEnd/.env
    ```
    Now, open `BackEnd/.env` and fill in your actual credentials for services like Cloudinary, etc. The default database and Redis URLs are already configured for local development.

### Step 2: Running the Development Environment

To start the application, simply run the `start_dev.sh` script from the project root.

```bash
# Make sure you are in the project's ROOT directory
./start_dev.sh
```

**What does this script do?**
1.  Starts the required background services (PostgreSQL & Redis) using Docker.
2.  Waits a few seconds for them to initialize.
3.  Starts the FastAPI server with auto-reload.

The API will be available at `http://localhost:8000`. You can stop the server at any time by pressing `CTRL+C`.

### Other Useful Commands

-   **Seed the Database:** To populate the database with test data, run this command from the project root in a **separate terminal**:
    ```bash
    python -m BackEnd.seed_data
    ```
-   **Run Database Migrations:** (Once Alembic is configured)
    ```bash
    alembic upgrade head
    ```
-   **Stop Docker Services:** To stop the database and cache, run:
    ```bash
    docker-compose -f BackEnd/docker-compose.yml down
    ```
