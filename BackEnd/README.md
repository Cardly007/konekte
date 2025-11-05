# Konekte Backend

This directory contains the Python/FastAPI backend for the Konekte application.

## Local Development Setup

### Prerequisites

- Python 3.10+
- Docker & Docker Compose
- `pip` for dependency management

### 1. Install Dependencies

Install all the required Python packages using the `requirements.txt` file. From the project root, run:

```bash
pip install -r BackEnd/requirements.txt
```

### 2. Set Up Environment Variables

Create a `.env` file in the `BackEnd/` directory by copying the example file.

```bash
# From the project root, run:
cp BackEnd/.env.example BackEnd/.env
```

Now, open the `BackEnd/.env` file and replace the placeholder values with your actual credentials.

### 3. Run the Database & Cache

The project uses a local PostgreSQL instance and a Redis instance running in Docker. From the project root, run:

```bash
docker-compose -f BackEnd/docker-compose.yml up -d
```

This will start the necessary background services.

### 4. Run Database Migrations

This project uses Alembic to manage database migrations. To apply all migrations and create the necessary tables, run:

```bash
alembic upgrade head
```

_Note: Alembic is not yet configured in this phase, but this command will be used once it is._

### 5. Seed the Database (Optional)

To populate your database with realistic test data, you can run the seeding script. This will create 50 fake users, profiles, photos, and interactions.

```bash
# Make sure you are in the project's ROOT directory
python -m BackEnd.seed_data
```

### 6. Run the Application

**IMPORTANT: This command must be run from the root directory of the project, NOT from inside the `BackEnd` directory.**

Once the database is running, you can start the FastAPI application. The `--app-dir` flag tells `uvicorn` where to find your application's code.

```bash
# Make sure you are in the project's ROOT directory
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --app-dir BackEnd
```

The API will be available at `http://localhost:8000`. You can access the auto-generated documentation at `http://localhost:8000/docs`.
