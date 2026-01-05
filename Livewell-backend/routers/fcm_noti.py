from fastapi import APIRouter, Header, Body, HTTPException
from utils.jwt_handler import verify_es256_token, verify_hs256_token
from supabase import Client, create_client
import os

router = APIRouter(prefix="/api/fcm-noti", tags=["fcm-noti"])


# Init supabase admin
url: str = os.getenv("SUPABASE_URL")
key: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
supabase_admin: Client = create_client(url, key)


def register_device(payload: dict, body: dict):
    """
    Check and insert the device token to the user's fcm_tokens table

    Args: Authorization header (contains jwt token) and body dictionary (contains user's device token and type)
    Returns: Success message
    """
    user_id = payload["sub"]

    try:
        # Check and insert to fcm_tokens table
        supabase_admin.table("fcm_tokens").upsert(
            {
                "id": user_id,
                "device_token": body["device_token"],
                "platform": body["platform"],
            }
        ).execute()

        return {"Device token registered successfully"}
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to register device token: {str(e)}"
        )


@router.post("/register-device/email")
async def register_device_email(
    authorization: str = Header(...), body: dict = Body(...)
):
    """
    Register the device token to the user (email)

    Args: Authorization header (contains jwt token) and body dictionary (contains user's device token and type)
    Returns: Success message
    """

    # Verify jwt
    payload = await verify_es256_token(authorization)

    register_device(payload, body)


@router.post("/register-device/google")
async def register_device_google(
    authorization: str = Header(...), body: dict = Body(...)
):
    """
    Register the device token to the user (google)

    Args: Authorization header (contains jwt token) and body dictionary (contains user's device token and type)
    Returns: Success message
    """

    # Verify jwt
    payload = await verify_hs256_token(authorization)

    register_device(payload, body)


def unregister_device(payload: dict):
    """
    Deleted the device token from the user's fcm_tokens table

    Args: Authorization header (contains jwt token)
    Returns: Success message
    """
    user_id = payload["sub"]

    try:
        # Delete from fcm_tokens table
        supabase_admin.table("fcm_tokens").delete().eq("id", user_id).execute()

        return {"Device token unregistered successfully"}
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to unregister device token: {str(e)}"
        )


@router.post("/unregister-device/email")
async def unregister_device_email(authorization: str = Header(...)):
    """
    Unregister the device token from the user (email)

    Args: Authorization header (contains jwt token)
    Returns: Success message
    """

    # Verify jwt
    payload = await verify_es256_token(authorization)

    unregister_device(payload)


@router.post("/unregister-device/google")
async def unregister_device_google(authorization: str = Header(...)):
    """
    Unregister the device token from the user (google)

    Args: Authorization header (contains jwt token)
    Returns: Success message
    """

    # Verify jwt
    payload = await verify_hs256_token(authorization)

    unregister_device(payload)
