from fastapi import APIRouter, HTTPException, Header, Body
from utils.jwt_handler import verify_es256_token, verify_hs256_token
from dotenv import load_dotenv
from supabase import Client, create_client
import os
from fastapi.responses import JSONResponse

router = APIRouter(prefix="/api/profile", tags=["profile"])


# Init supabase admin
url: str = os.getenv("SUPABASE_URL")
key: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
supabase_admin: Client = create_client(url, key)

# ============================================================================
# Functions
# ============================================================================


async def create_profile(payload: dict, body: dict):
    """
    Insert more user's information in profile table in database

    Args:
        payload (dict): JWT payload (contains user's information)
        body (dict): Body dictionary (contains user's information)
    """
    user_id = payload["sub"]

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

        except Exception as e:
            raise HTTPException(
                status_code=500, detail=f"Failed to insert users info: {str(e)}"
            )
    else:
        raise HTTPException(status_code=400, detail="User not found")


async def update_profile(payload: dict, body: dict = Body(...)):
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

    try:
        # Check if the user exists in your database
        result = (
            supabase_admin.table("users_info").select("*").eq("id", user_id).execute()
        )

    except Exception as e:
        raise HTTPException(status_code=400, detail=f"User not found: {str(e)}")

    try:
        # Update user's info
        supabase_admin.table("users_info").update(
            {
                "suburb": suburb,
                "postcode": postcode,
                "frailty_score": frailty_score,
            }
        ).eq("id", user_id).execute()

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to update user info: {str(e)}"
        )


async def get_profile(payload: dict):
    """
    Get user's profile from Supabase

    Args:
        payload (dict): Payload dictionary (contains user's information)

    Returns:
        User's info from Supabase
    """
    user_id = payload["sub"]

    try:
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

    except Exception as e:
        raise HTTPException(status_code=404, detail=f"User's info not found: {str(e)}")

    # Combine profile and info
    result = {
        **profile_result.data[0],
        **(info_result.data[0] if info_result.data else {}),
    }

    return result


# ============================================================================
# APIs
# ============================================================================


@router.post("/email")
async def create_profile_email(
    authorization: str = Header(...), body: dict = Body(...)
):
    """
    Create profile for email

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (dict): Body dictionary (contains user's information)

    Returns:
        Successful message
    """
    payload = await verify_es256_token(authorization)

    await create_profile(payload, body)

    return {"User's info created successfully"}


@router.post("/google")
async def create_profile_google(
    authorization: str = Header(...), body: dict = Body(...)
):
    """
    Create profile for google

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (dict): Body dictionary (contains user's information)

    Returns:
        Successful message
    """
    payload = await verify_hs256_token(authorization)

    await create_profile(payload, body)

    return {"User's info created successfully"}


@router.get("/email")
async def get_profile_email(authorization: str = Header(...)):
    """
    Get user's profile (email)

    Args:
        authorization (str): Authorization header (contains jwt token)

    Returns:
        User's info from Supabase
    """

    payload = await verify_es256_token(authorization)

    return await get_profile(payload)


@router.get("/google")
async def get_profile_google(authorization: str = Header(...)):
    """
    Get user's profile (google)

    Args:
        authorization (str): Authorization header (contains jwt token)

    Returns:
        User's info from Supabase
    """

    payload = await verify_hs256_token(authorization)

    return await get_profile(payload)


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

    await update_profile(payload, body)
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

    await update_profile(payload, body)
    return {"User's info updated successfully"}
