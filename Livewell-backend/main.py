from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routers import google_auth, profile

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
    return {"Welcome to Livewell Backend": "Livewell Backend is running"}


@app.get("/health")
def read_health():
    return {"statusCode": 200, "message": "Backend is running"}


# Routers
app.include_router(google_auth.router)
app.include_router(profile.router)
