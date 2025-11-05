import redis.asyncio as redis
from fastapi import FastAPI
from fastapi_limiter import FastAPILimiter
from starlette.middleware.cors import CORSMiddleware

from app.core.config import settings

# Initialize the FastAPI app
app = FastAPI(
    title="Konekte API",
    version="1.0.0",
    description="The official API for the Konekte dating application.",
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for now (can be restricted later)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup():
    """
    Initialize Redis connection and rate limiter on startup.
    """
    redis_client = redis.from_url(settings.REDIS_URL, encoding="utf-8", decode_responses=True)
    await FastAPILimiter.init(redis_client)

@app.get("/")
def read_root():
    """
    Root endpoint to check if the API is running.
    """
    return {"status": "ok", "message": "Welcome to the Konekte API"}

# Here we would include the API routers from app.api.v1
# Example: from app.api.v1 import auth
# app.include_router(auth.router, prefix="/api/v1/auth")
