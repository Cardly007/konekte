# Konekte Backend

This directory contains the Python/FastAPI backend for the Konekte application.

## Local Development Setup

This guide provides two ways to set up the backend environment.

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
    Make sure the `DATABASE_URL` and `REDIS_URL` in your `BackEnd/.env` file point to your services.

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

### `Connection closed by server` (Redis Error)

This error almost always means your Redis instance requires a password, but the application is not providing one.

**Solution:**
1.  Open your `BackEnd/.env` file.
2.  Add a variable for your Redis password:
    ```
    REDIS_PASSWORD=your_actual_redis_password
    ```
3.  Update the `REDIS_URL` to include this password. The format should be:
    ```
    REDIS_URL=redis://:${REDIS_PASSWORD}@localhost:6379
    ```
4.  If your Redis has **no password**, the URL should simply be:
    ```
    REDIS_URL=redis://localhost:6379
    ```

After saving the `.env` file, restart the application with `./start_dev.sh`.
