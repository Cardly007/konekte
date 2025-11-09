# Konekte Backend

This directory contains the Python/FastAPI backend for the Konekte application.

## Local Development Setup

### Prerequisites

- Python 3.10+
- Docker & Docker Compose
- `pip` for dependency management

### 1. Install Dependencies

Install all the required Python packages using the `requirements.txt` file (it's recommended to do this from the project root).

```bash
pip install -r BackEnd/requirements.txt
```

### 2. Set Up Environment Variables

Create a `.env` file in this `BackEnd/` directory by copying the example file.

```bash
# From the project root, run:
cp BackEnd/.env.example BackEnd/.env
```

Now, open `BackEnd/.env` and fill in your actual credentials. The application is configured to find this file automatically.

### 3. Run the Database & Cache

The project uses a local PostgreSQL instance and a Redis instance running in Docker. You can start these services from the project root.

```bash
docker-compose -f BackEnd/docker-compose.yml up -d
```

### 4. Run Database Migrations

This project uses Alembic to manage database migrations. To apply all migrations and create the necessary tables, run:

```bash
alembic upgrade head
```

_Note: Alembic is not yet configured in this phase, but this command will be used once it is._

### 5. Seed the Database (Optional)

To populate your database with test data, you can run the seeding script from the project root.

```bash
python -m BackEnd.seed_data
```

### 6. Run the Application

You can now start the FastAPI application. The `--app-dir` flag tells `uvicorn` where to find the `app` module.

**Run this command from the project's root directory:**
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --app-dir BackEnd
```

The API will be available at `http://localhost:8000`. You can access the auto-generated documentation at `http://localhost:8000/docs`.
