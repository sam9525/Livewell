from fastapi import APIRouter, HTTPException, Body, Header
from pydantic import BaseModel
from utils.jwt_handler import verify_hs256_token
import os
from supabase import Client, create_client
from google import genai
from google.genai import types

router = APIRouter(prefix="/api/chatbot", tags=["chatbot"])


# ============================================================================
# Request Models
# ============================================================================


class ChatbotRequest(BaseModel):
    message: str


# Init supabase admin
url: str = os.getenv("SUPABASE_URL")
key: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
supabase_admin: Client = create_client(url, key)

# Init Gemini
genai_client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

# ============================================================================
# Functions
# ============================================================================


async def chatbot(payload: dict, body: ChatbotRequest):
    """
    Chat with AI chatbot

    Args:
        payload (dict): Payload dictionary (contains user's information)
        body (dict): Body dictionary (contains user's information)

    Returns:
        Response message from AI chatbot
    """
    user_id = payload["sub"]

    try:
        # Call the improved function
        user_info = supabase_admin.rpc(
            "get_user_data_tables", {"user_uuid": user_id}
        ).execute()

    except Exception as e:
        raise HTTPException(status_code=400, detail=f"User's info not found: {str(e)}")

    client = genai_client

    response = client.models.generate_content(
        model="gemini-3-flash-preview",
        contents=body.message,
        config=types.GenerateContentConfig(
            system_instruction=f"You are a knowledgeable, empathetic, and supportive Health & Wellness Assistant. Your goal is to help users improve their physical and mental well-being through sustainable lifestyle changes, education, and encouragement. You specialize in nutrition, fitness, sleep hygiene, mindfulness, and stress management. You need to read the user's info below before replying, reply should be under 200 words.\n\nUser's info: {user_info.data}",
            temperature=0.7,
            top_p=0.95,
            top_k=40,
            max_output_tokens=60000,
        ),
    )

    return response.text


# ============================================================================
# API
# ============================================================================


@router.post("/google")
async def chat_google(
    authorization: str = Header(...), body: ChatbotRequest = Body(...)
):
    """
    Chat with AI chatbot

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (dict): Body dictionary (contains user's information)

    Returns:
        Response message from AI chatbot
    """

    payload = await verify_hs256_token(authorization)

    return await chatbot(payload, body)
