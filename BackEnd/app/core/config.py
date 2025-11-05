from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    # Base settings
    ENVIRONMENT: str = "development"

    # Database
    DATABASE_URL: str

    # Redis
    REDIS_URL: str

    # JWT
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str

    # Cloudinary
    CLOUDINARY_CLOUD_NAME: str
    CLOUDINARY_API_KEY: str
    CLOUDINARY_API_SECRET: str

    # Stripe
    STRIPE_SECRET_KEY: str
    STRIPE_WEBHOOK_SECRET: str

    # Twilio
    TWILIO_ACCOUNT_SID: str
    TWILIO_AUTH_TOKEN: str
    TWILIO_VERIFY_SERVICE_SID: str

    secret_key: str | None = None
    firebase_project_id: str | None = None
    firebase_private_key: str | None = None


    # Sentry
    SENTRY_DSN: str | None = None

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding='utf-8')

settings = Settings()
