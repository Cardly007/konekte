# Konekte Backend

This directory contains the Python/FastAPI backend for the Konekte application.

## 🚀 Quick Start (Recommended)

This project uses Docker to provide a consistent and easy-to-manage development environment.

### Prerequisites
- Docker & Docker Compose
- Python 3.10+
- `pip` for dependency management

### Step 1: Install Dependencies
This only needs to be done once. From the project root, run:
```bash
pip install -r BackEnd/requirements.txt
```
*(Remember to re-run this command if you pull new changes that modify this file.)*

### Step 2: Start Everything
Simply run the `start.sh` script from the project root.
```bash
./start.sh
```
**What does this script do?**
1.  Creates a `.env` file from the example if it doesn't exist.
2.  Stops and removes any old Docker containers to ensure a clean start.
3.  Starts new containers for PostgreSQL and Redis.
4.  Waits for them to initialize.
5.  Starts the FastAPI server with auto-reload.

The API will be available at `http://localhost:8000`.

---

## Manual Setup & Other Commands

### Environment Configuration
The application is configured via the `BackEnd/.env` file. The `start.sh` script creates this file for you on the first run. You can edit it to change default passwords or connect to external services.

### Running Commands Manually
-   **Start Docker Services Only:**
    ```bash
    docker-compose -f BackEnd/docker-compose.yml up -d
    ```
-   **Stop Docker Services:**
    ```bash
    docker-compose -f BackEnd/docker-compose.yml down
    ```
-   **Seed the Database:**
    To populate the database with test data, run this command in a separate terminal:
    ```bash
    python -m BackEnd.seed_data
    ```
-   **Run the Server Only** (if Docker services are already running):
    ```bash
    uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --app-dir BackEnd
    ```

### Connecting to an External Database
If you wish to use your own database instead of the one provided in Docker:
1.  Stop the Docker services: `docker-compose -f BackEnd/docker-compose.yml down`
2.  Edit your `BackEnd/.env` file and update `DATABASE_URL` and the `REDIS_*` variables to point to your external services.
3.  Start the server manually: `uvicorn app.main:app ...`
