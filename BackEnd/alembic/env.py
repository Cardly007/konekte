import os
import sys
from logging.config import fileConfig
from dotenv import load_dotenv

from sqlalchemy import engine_from_config, pool
from alembic import context

# --- CUSTOM SETUP ---

# Add the project's root directory to the Python path
# This allows Alembic to import modules from the 'BackEnd' package
project_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
sys.path.insert(0, project_dir)

# Define the path to the .env file and load it
# The .env file is expected to be in the 'BackEnd' directory
dotenv_path = os.path.join(project_dir, 'BackEnd', '.env')
load_dotenv(dotenv_path)

# Now that .env is loaded, we can import the app's settings and models
from BackEnd.app.core.config import settings
from BackEnd.app.models import *  # Import all models for autodiscovery
from BackEnd.app.models.base import DeclarativeBase

# --- END CUSTOM SETUP ---

# Standard Alembic configuration
config = context.config
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Set the SQLAlchemy URL from our settings
config.set_main_option('sqlalchemy.url', settings.DATABASE_URL)

target_metadata = DeclarativeBase.metadata

def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online() -> None:
    """Run migrations in 'online' mode."""
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)
        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
