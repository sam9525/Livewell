from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
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
)

app = FastAPI()

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
