# Konekte Backend

This directory contains the Python/FastAPI backend for the Konekte application.

## Local Development Setup

This guide provides two ways to set up the backend environment, depending on your needs.

---

### Scenario A: Connecting to an Existing Database (Your Current Setup)

Follow these steps if you already have a PostgreSQL and Redis instance running, as is your case.

1.  **Install Dependencies**
    From the project root, install all required Python packages.
    ```bash
    pip install -r BackEnd/requirements.txt
    ```
    *(Note: Re-run this command anytime you pull new changes to the project.)*

2.  **Configure Your Environment**
    Create your local environment file by copying the example.
    ```bash
    # From the project root, run:
    cp BackEnd/.env.example BackEnd/.env
    ```
    Open `BackEnd/.env` and ensure the `DATABASE_URL` and `REDIS_URL` point to your existing services. The default is `localhost:5432` for PostgreSQL and `localhost:6379` for Redis.

3.  **Run the Application**
    Simply run the `start_dev.sh` script from the project root. This script will start the FastAPI server.
    ```bash
    # Make sure you are in the project's ROOT directory
    ./start_dev.sh
    ```
    The API will be available at `http://localhost:8000`.

---

### Scenario B: Starting Fresh with Docker

Follow these steps if you are a new developer on the project and want to run the provided database and cache services using Docker.

1.  **Install Dependencies & Configure Environment**
    Follow steps 1 and 2 from Scenario A. The default values in the `.env` file are already configured for this Docker setup.

2.  **Start Docker Services**
    From the project root, run the following command to start the PostgreSQL and Redis containers.
    ```bash
    docker-compose -f BackEnd/docker-compose.yml up -d
    ```

3.  **Run the Application**
    Once the Docker services are running, start the FastAPI server.
    ```bash
    ./start_dev.sh
    ```

### Other Useful Commands

-   **Seed the Database:** To populate the database with test data, run this command from the project root in a **separate terminal**:
    ```bash
    python -m BackEnd.seed_data
    ```
-   **Stop Docker Services:** To stop the database and cache started with Scenario B, run:
    ```bash
    docker-compose -f BackEnd/docker-compose.yml down
    ```
