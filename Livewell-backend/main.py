from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from dotenv import load_dotenv

load_dotenv()

from routers import (
    google_auth,
    profile,
    fcm_noti,
    tracking_data,
    medications,
    vaccinations,
    chatbot,
    recommendation,
    local_resources,
)
from utils import goal_recommendation
from apscheduler.schedulers.asyncio import AsyncIOScheduler

# Scheduler setup
scheduler = AsyncIOScheduler()


@asynccontextmanager
async def lifespan(app: FastAPI):
    scheduler.add_job(
        goal_recommendation.prepare_recommendation, "cron", day_of_week="mon", hour=0
    )
    scheduler.add_job(
        goal_recommendation.send_fcm_noti, "cron", day_of_week="mon", hour=8
    )
    scheduler.start()
    yield
    # Shutdown
    scheduler.shutdown()


app = FastAPI(lifespan=lifespan)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def read_root():
    return {"Welcome to Livewell Backend"}


@app.get("/health")
def read_health():
    return {"Backend is running"}


# Routers
app.include_router(google_auth.router)
app.include_router(profile.router)
app.include_router(fcm_noti.router)
app.include_router(tracking_data.router)
app.include_router(medications.router)
app.include_router(vaccinations.router)
app.include_router(chatbot.router)
app.include_router(recommendation.router)
app.include_router(local_resources.router)
