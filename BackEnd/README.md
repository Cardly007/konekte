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

### Step 2: Configure Environment
The `start.sh` script will create a `.env` file for you on its first run. Open `BackEnd/.env` and ensure the variables match your setup. For the Docker setup, the defaults are usually fine.

### Step 3: Start Everything
Simply run the `start.sh` script from the project root.
```bash
./start.sh
```
The API will be available at `http://localhost:8000`.

### Step 4: Apply Database Migrations
After starting the services for the first time, you need to create the database tables. Open a **new terminal** and run the following command from the project root:
```bash
alembic -c BackEnd/alembic.ini upgrade head
```
Your database is now ready.

---

## Other Useful Commands

-   **Seed the Database:** To populate the database with test data, run this command from the project root in a separate terminal:
    ```bash
    python -m BackEnd.seed_data
    ```
-   **Stop Docker Services:**
    ```bash
    docker-compose -f BackEnd/docker-compose.yml down
    ```
-   **Creating a New Migration:** If you change the database models, you'll need to create a new migration script.
    ```bash
    alembic -c BackEnd/alembic.ini revision --autogenerate -m "Your description of the change"
    ```
---

## Manual Setup

If you wish to use your own database instead of the one provided in Docker:
1.  Ensure your external services (PostgreSQL, Redis) are running.
2.  Edit your `BackEnd/.env` file and update `DATABASE_URL` and the `REDIS_*` variables to point to your services.
3.  Apply the database migrations: `alembic -c BackEnd/alembic.ini upgrade head`
4.  Start the server manually: `uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --app-dir BackEnd`
