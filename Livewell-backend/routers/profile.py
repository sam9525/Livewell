from fastapi import APIRouter, HTTPException, Header, Body
from utils.jwt_handler import decode_jwt
from dotenv import load_dotenv
from supabase import create_client
import os
from fastapi.responses import JSONResponse

router = APIRouter(prefix="/api/profile", tags=["profile"])


@router.get("")
async def get_profile():
    return {"Get profile"}


async def create_profile(payload: dict, body: dict):
    """
    Insert more user's information in profile table in database

    Args:
        payload (dict): JWT payload (contains user's information)
        body (dict): Body dictionary (contains user's information)

    Returns:
        Successful message
    """
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

            return {"User's info created successfully"}

        except Exception as e:
            raise HTTPException(
                status_code=500, detail=f"Failed to insert users info: {str(e)}"
            )
    else:
        raise HTTPException(status_code=400, detail="User not found")


async def verify_es256_token(authorization: str = Header(...), body: dict = Body(...)):
    """
    Verify es256 token

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (dict): Body dictionary (contains user's information)

    Returns:
        payload (dict): JWT decoded information
    """
    JWT_ALGORITHM = "ES256"

    # Verify jwt token
    if authorization.startswith("Bearer "):
        authorization = authorization.split(" ")[1]

    payload = decode_jwt(authorization, JWT_ALGORITHM)

    return payload


async def verify_hs256_token(authorization: str = Header(...), body: dict = Body(...)):
    """
    Verify hs256 token

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (dict): Body dictionary (contains user's information)

    Returns:
        payload (dict): JWT decoded information
    """
    JWT_ALGORITHM = "HS256"

    # Verify jwt token
    if authorization.startswith("Bearer "):
        authorization = authorization.split(" ")[1]

    payload = decode_jwt(authorization, JWT_ALGORITHM)

    return payload


@router.post("/email")
async def create_profile_email(
    authorization: str = Header(...), body: dict = Body(...)
):
    """
    Create profile for email

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (dict): Body dictionary (contains user's information)
    """
    payload = await verify_es256_token(authorization)

    await create_profile(payload, body)


@router.post("/google")
async def create_profile_google(
    authorization: str = Header(...), body: dict = Body(...)
):
    """
    Create profile for google

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (dict): Body dictionary (contains user's information)
    """
    payload = await verify_hs256_token(authorization)

    await create_profile(payload, body)


@router.get("/email")
async def get_profile_email(authorization: str = Header(...)):
    """
    Get user's profile

    Args:
        authorization (str): Authorization header (contains jwt token)

    Returns:
        User's info from Supabase
    """

    payload = await verify_es256_token(authorization)

    user_id = payload["sub"]

    # Init supabase admin
    supabase_admin = create_client(
        supabase_url=os.getenv("SUPABASE_URL"),
        supabase_key=os.getenv("SUPABASE_SERVICE_ROLE_KEY"),
    )

    # Get user's name and email from profiles table
    profile_result = (
        supabase_admin.table("profiles")
        .select("user_name, email")
        .eq("id", user_id)
        .execute()
    )

    # Get user's info
    info_result = (
        supabase_admin.table("users_info").select("*").eq("id", user_id).execute()
    )

    # Combine profile and info
    result = {
        **profile_result.data[0],
        **(info_result.data[0] if info_result.data else {}),
    }

    return result


@router.get("/google")
async def get_profile_google(authorization: str = Header(...)):
    """
    Get user's profile

    Args:
        authorization (str): Authorization header (contains jwt token)

    Returns:
        User's info from Supabase
    """

    payload = await verify_hs256_token(authorization)

    user_id = payload["sub"]

    # Init supabase admin
    supabase_admin = create_client(
        supabase_url=os.getenv("SUPABASE_URL"),
        supabase_key=os.getenv("SUPABASE_SERVICE_ROLE_KEY"),
    )

    # Get user's name and email from profiles table
    profile_result = (
        supabase_admin.table("profiles")
        .select("user_name, email")
        .eq("id", user_id)
        .execute()
    )

    # Get user's info
    info_result = (
        supabase_admin.table("users_info").select("*").eq("id", user_id).execute()
    )

    # Combine profile and info
    result = {
        **profile_result.data[0],
        **(info_result.data[0] if info_result.data else {}),
    }

    return result


def update_profile(payload: dict, body: dict = Body(...)):
    """
    Update user's profile

    Args:
        payload (dict): Payload dictionary (contains user's information)
        body (dict): Body dictionary (contains user's information)
    """
    user_id = payload["sub"]
    suburb = body.get("suburb")
    postcode = body.get("postcode")
    frailty_score = body.get("frailtyScore")

    # Init supabase admin
    supabase_admin = create_client(
        supabase_url=os.getenv("SUPABASE_URL"),
        supabase_key=os.getenv("SUPABASE_SERVICE_ROLE_KEY"),
    )

    try:
        supabase_admin.table("users_info").select("*").eq("id", user_id).execute()
    except Exception as e:
        raise HTTPException(status_code=404, detail=f"User not found: {str(e)}")

    try:
        # Update user's info
        result = (
            supabase_admin.table("users_info")
            .update(
                {
                    "suburb": suburb,
                    "postcode": postcode,
                    "frailty_score": frailty_score,
                }
            )
            .eq("id", user_id)
            .execute()
        )
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to update user info: {str(e)}"
        )


@router.put("/email")
async def update_profile_email(
    authorization: str = Header(...), body: dict = Body(...)
):
    """
    Update user's profile for email login

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (dict): Body dictionary (contains user's information)

    Returns:
        Successful message
    """
    payload = await verify_es256_token(authorization)
    update_profile(payload, body)

    return {"User's info updated successfully"}


@router.put("/google")
async def update_profile_google(
    authorization: str = Header(...), body: dict = Body(...)
):
    """
    Update user's profile for google login

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (dict): Body dictionary (contains user's information)

    Returns:
        Successful message
    """
    payload = await verify_hs256_token(authorization)
    update_profile(payload, body)

    return {"User's info updated successfully"}
