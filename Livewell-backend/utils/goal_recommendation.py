from apscheduler.schedulers.asyncio import AsyncIOScheduler
from contextlib import asynccontextmanager
from fastapi import FastAPI
import os
import json
from utils import init_supabase
from google import genai
from google.genai import types
from fastapi import APIRouter
from typing import List
from models import (
    GoalDetails,
    RecommendationResponse,
    WeeklyGoal,
)
import firebase_admin
from firebase_admin import credentials, messaging
import logging
import asyncio


router = APIRouter(prefix="/api/goal-recommendation", tags=["goal-recommendation"])

# Init supabase admin
supabase_admin = init_supabase()

# Init Gemini
genai_client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))


recommendations = []


async def get_users():
    """
    Get all users from Supabase

    Returns:
        list: List of user IDs
    """

    try:
        users = supabase_admin.auth.admin.list_users()
        return [{"id": user.id} for user in users]
    except Exception as e:
        print(f"Error getting users: {e}")
        return None


def generate_recommendation(user):
    """
    Generate recommendation for a user

    Args:
        user (dict): User ID

    Returns:
        RecommendationResponse: Recommendation response
    """

    user_id = user["id"]

    # Call the function from Supabase SQL function
    user_info = supabase_admin.rpc(
        "get_user_data_tables", {"user_uuid": user_id}
    ).execute()

    # Find user's device token from Supabase
    fcm_token_res = (
        supabase_admin.table("fcm_tokens")
        .select("device_token")
        .eq("id", user_id)
        .execute()
    )

    if not fcm_token_res.data:
        return None

    # Configure the model
    config = types.GenerateContentConfig(
        system_instruction=(
            f"You are a knowledgeable, empathetic, and supportive Health & Wellness Assistant. "
            f"Your goal is to recommend weekly goals for users to improve their physical and mental well-being. "
            f"You specialize in nutrition, fitness, sleep hygiene, mindfulness, and stress management. "
            f"You need to read the user's info below and reply should be in the format of JSON with just only two number for target_water_intake_ml and target_steps with just a sentence of description, "
            f"like {{'Weekly Goal': {{'target_water_intake_ml': '1000', 'target_steps': '7000', 'description': 'Drink more water you have taken flu shot.'}}}}.\n\n "
            f"User's info: {user_info.data}"
        ),
        temperature=0.7,
        top_p=0.95,
        top_k=40,
        max_output_tokens=2048,
        response_mime_type="application/json",
    )

    # Generate response
    response = genai_client.models.generate_content(
        model="gemini-3-flash-preview",
        contents="Please generated weekly goals for user",
        config=config,
    )

    # Combine the response with user_id and user's device token
    return RecommendationResponse(
        user_id=user_id,
        device_token=fcm_token_res.data[0]["device_token"],
        recommendation=json.loads(response.text),
    )


async def prepare_recommendation():
    """
    AI generated recommendation for user, based on the user information on Supabase
    """

    recommendations.clear()

    # Get all users
    users = await get_users()

    if users:
        results = await asyncio.gather(
            *(asyncio.to_thread(generate_recommendation, user) for user in users)
        )

        for result in results:
            if result:
                recommendations.append(result)


async def send_fcm_noti():
    """
    Send FCM notification to specific user, using their device token on Supabase
    """

    for rec in recommendations:
        user_id = rec.user_id
        token = rec.device_token
        title = "Your Weekly Health Goals"
        recommend_type = "goal_recommendation"
        target_steps = rec.recommendation.weekly_goal.target_steps
        target_water_intake_ml = rec.recommendation.weekly_goal.target_water_intake_ml
        description = rec.recommendation.weekly_goal.description

        try:
            message = messaging.Message(
                data={
                    "title": title,
                    "type": recommend_type,
                    "target_steps": str(target_steps),
                    "target_water_intake_ml": str(target_water_intake_ml),
                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                },
                token=token,
            )

            response = messaging.send(message)
            print(f"Successfully sent message: {response}")

        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

        try:
            # Store ommendation in database
            supabase_admin.table("goal_recommendations").insert(
                {
                    "title": title,
                    "type": recommend_type,
                    "steps_target": target_steps,
                    "water_intake_ml_target": target_water_intake_ml,
                    "description": description,
                }
            ).eq("id", user_id).execute()

        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
