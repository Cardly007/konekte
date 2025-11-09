# Konekte Backend

This directory contains the Python/FastAPI backend for the Konekte application.

## Local Development Setup

### Step 1: Initial Configuration (Do this once)

1.  **Install Dependencies**
    From the project root, install all required Python packages.
    ```bash
    pip install -r BackEnd/requirements.txt
    ```
    *(Note: Re-run this command anytime you pull new changes to the project.)*

2.  **Configure Your Environment**
    Create your local environment file by copying the example.
    ```bash
    cp BackEnd/.env.example BackEnd/.env
    ```
    Now, open `BackEnd/.env` and configure the variables to match your setup.

---

### Step 2: Running the Application

This project supports two primary ways of running the backend.

#### Scenario A: Connecting to an Existing Database (Your Current Setup)

If you already have your own PostgreSQL and Redis services running, this is the method for you.

1.  **Configure Your `.env` File**
    Make sure the variables in your `BackEnd/.env` file correctly point to your services.
    - `DATABASE_URL`: Your full PostgreSQL connection string.
    - `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD`: Your Redis connection details. If your Redis has no password, leave `REDIS_PASSWORD` blank.

2.  **Run the App**
    Execute the startup script from the project root:
    ```bash
    ./start_dev.sh
    ```

#### Scenario B: Starting Fresh with Docker

If you want to run the provided services, use Docker.

1.  **Start Docker Services**
    ```bash
    docker-compose -f BackEnd/docker-compose.yml up -d
    ```

2.  **Run the App**
    ```bash
    ./start_dev.sh
    ```

---

## Troubleshooting

### `Connection closed by server` or `Authentication required` (Redis Error)

This error means your Redis instance requires a password, but the application is not providing the correct one.

**Solution:**
1.  Open your `BackEnd/.env` file.
2.  Find the Redis configuration section.
3.  Set `REDIS_PASSWORD` to your actual Redis password.
    ```env
    REDIS_HOST=localhost
    REDIS_PORT=6379
    REDIS_PASSWORD=your_actual_redis_password
    ```
4.  If your Redis has **no password**, make sure the line is empty:
    ```env
    REDIS_PASSWORD=
    ```
After saving the `.env` file, restart the application with `./start_dev.sh`.
