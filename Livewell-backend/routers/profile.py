from fastapi import APIRouter, HTTPException, Header, Body
from utils.jwt_handler import decode_jwt
from dotenv import load_dotenv
from supabase import create_client
import os

router = APIRouter(prefix="/api/profile", tags=["profile"])

JWT_ALGORITHM = "HS256"


@router.get("")
async def get_profile():
    return {"message": "Get profile"}


@router.post("")
async def create_profile(authorization: str = Header(...), body: dict = Body(...)):
    """
    Insert more user's information in profile table in database

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (dict): Body dictionary (contains user's information)

    Returns:
        dict: Response dictionary (contains status code and message)
    """

    JWT_ALGORITHM = "ES256" if body.get("isEmail") else "HS256"
    print(JWT_ALGORITHM)

    # Verify jwt token
    if authorization.startswith("Bearer "):
        authorization = authorization.split(" ")[1]

    payload = decode_jwt(authorization, JWT_ALGORITHM)

    user_id = payload["sub"]

    load_dotenv()

    # Init supabase admin
    supabase_admin = create_client(
        supabase_url=os.getenv("SUPABASE_URL"),
        supabase_key=os.getenv("SUPABASE_SERVICE_ROLE_KEY"),
    )

    # Check if the user already exists in your database
    result = supabase_admin.table("profiles").select("*").eq("id", user_id).execute()

    # User exists
    if result.data:
        try:
            # Get user's information from body
            attributes = {
                "id": user_id,
                "age_range": body.get("ageRange"),
                "gender": body.get("gender"),
                "exercise_frequency": body.get("exerciseFrequency"),
                "exercise_types": body.get("exerciseTypes"),
                "social_frequency": body.get("socialFrequency"),
                "main_goals": body.get("mainGoals"),
                "takes_medications": body.get("takesMedications"),
                "medication_details": body.get("medicationDetails"),
            }

            # Insert into user's profile
            supabase_admin.table("users_info").insert(attributes).execute()

            return {"statusCode": 200, "message": "User's info created successfully"}

        except Exception as e:
            raise HTTPException(
                status_code=500, detail=f"Failed to insert users info: {str(e)}"
            )
    else:
        raise HTTPException(status_code=400, detail="User not found")
