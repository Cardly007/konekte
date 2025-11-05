# Konekte Backend

This directory contains the Python/FastAPI backend for the Konekte application.

## Local Development Setup

### Prerequisites

- Python 3.10+
- Docker & Docker Compose
- `pip` for dependency management

### 1. Install Dependencies

Install all the required Python packages using the `requirements.txt` file.

```bash
pip install -r requirements.txt
```

### 2. Set Up Environment Variables

Create a `.env` file in this directory by copying the example file.

```bash
cp .env.example .env
```

Now, open the `.env` file and replace the placeholder values with your actual credentials for services like Cloudinary, Stripe (in test mode), and Twilio. For local development, the default database and Redis URLs should work out of the box with the provided `docker-compose.yml`.

### 3. Run the Database & Cache

The project uses a local PostgreSQL instance and a Redis instance running in Docker. You can start these services using Docker Compose.

```bash
docker-compose up -d
```

This will start a PostgreSQL container and a Redis container. The database will be accessible at `postgresql://user:password@localhost:5432/konekte`.

### 4. Run Database Migrations

This project uses Alembic to manage database migrations. To apply all migrations and create the necessary tables, run:

```bash
alembic upgrade head
```

_Note: Alembic is not yet configured in this phase, but this command will be used once it is._

### 5. Run the Application

Once the database is running, you can start the FastAPI application using `uvicorn`. The application will reload automatically when you make code changes. The entry point is `app.main:app`.

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --app-dir BackEnd
```

The API will be available at `http://localhost:8000`. You can access the auto-generated documentation at `http://localhost:8000/docs`.
