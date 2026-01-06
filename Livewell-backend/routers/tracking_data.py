from fastapi import APIRouter, HTTPException, Header, Body, Query
from pydantic import BaseModel
from utils.jwt_handler import verify_es256_token, verify_hs256_token
from dotenv import load_dotenv
from supabase import Client, create_client
import os
from datetime import datetime, timedelta
from typing import Optional

router = APIRouter(prefix="/api/tracking", tags=["tracking"])


# ============================================================================
# Request Models
# ============================================================================


class UpdateCurrentTrackingRequest(BaseModel):
    current_steps: int
    current_water_intake_ml: int


class UpdateTargetTrackingRequest(BaseModel):
    target_steps: int
    target_water_intake_ml: int


# Init supabase admin
url: str = os.getenv("SUPABASE_URL")
key: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
supabase_admin: Client = create_client(url, key)


# ============================================================================
# Functions
# ============================================================================


def get_current_week_dates():
    """
    Get start and end dates for the current week (Monday to Sunday)

    Returns:
        tuple: (start_date, end_date) in YYYY-MM-DD format
    """
    today = datetime.now()
    start_of_week = today - timedelta(days=today.weekday())
    end_of_week = start_of_week + timedelta(days=6)
    return start_of_week.strftime("%Y-%m-%d"), end_of_week.strftime("%Y-%m-%d")


async def get_tracking_data(
    payload: dict, start_date: Optional[str] = None, end_date: Optional[str] = None
):
    """
    Get user's tracking data for a date range

    Args:
        payload (dict): JWT payload (contains user's information)
        start_date (str): Start date in YYYY-MM-DD format
        end_date (str): End date in YYYY-MM-DD format

    Returns:
        List of tracking data records
    """
    user_id = payload["sub"]

    # Default to current week if dates not provided
    if not start_date or not end_date:
        start_date, end_date = get_current_week_dates()

    try:
        # Get tracking data for date range
        result = (
            supabase_admin.table("tracking_data")
            .select("*")
            .eq("id", user_id)
            .gte("today_date", start_date)
            .lte("today_date", end_date)
            .order("today_date")
            .execute()
        )

        if not result.data:
            raise HTTPException(
                status_code=400, detail="User tracking data not found in Supabase"
            )

        print(result.data)

        return result.data

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to get user's tracking data: {str(e)}"
        )


async def get_today_tracking(payload: dict):
    """
    Get user's tracking data for today

    Args:
        payload (dict): JWT payload (contains user's information)

    Returns:
        Today's tracking data record
    """
    user_id = payload["sub"]
    today = datetime.now().strftime("%Y-%m-%d")

    try:
        # Get today's tracking data
        result = (
            supabase_admin.table("tracking_data")
            .select("*")
            .eq("id", user_id)
            .eq("today_date", today)
            .execute()
        )

        if not result.data:
            raise HTTPException(
                status_code=400,
                detail="User today's tracking data not found in Supabase",
            )

        return result.data

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to get user's tracking data for current day: {str(e)}",
        )


async def update_current_tracking(payload: dict, body: UpdateCurrentTrackingRequest):
    """
    Update user's current tracking data (steps and water intake)

    Args:
        payload (dict): JWT payload (contains user's information)
        body (UpdateCurrentTrackingRequest): Request body with current_steps and current_water_intake_ml
    """
    user_id = payload["sub"]
    today = datetime.now().strftime("%Y-%m-%d")

    current_steps = body.current_steps
    current_water_intake_ml = body.current_water_intake_ml

    try:
        # Check if today's tracking data exists
        check_result = (
            supabase_admin.table("tracking_data")
            .select("*")
            .eq("id", user_id)
            .eq("today_date", today)
            .execute()
        )

        if not check_result.data:
            raise HTTPException(
                status_code=400,
                detail="User today's tracking data not found in Supabase",
            )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=400, detail=f"User today's tracking data not found: {str(e)}"
        )

    try:
        # Update current tracking data
        supabase_admin.table("tracking_data").update(
            {
                "current_steps": current_steps,
                "current_water_intake_ml": current_water_intake_ml,
            }
        ).eq("id", user_id).eq("today_date", today).execute()

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to update user's current tracking data: {str(e)}",
        )


async def update_target_tracking(payload: dict, body: UpdateTargetTrackingRequest):
    """
    Update user's target tracking data (target steps and water intake)

    Args:
        payload (dict): JWT payload (contains user's information)
        body (UpdateTargetTrackingRequest): Request body with target_steps and target_water_intake_ml
    """
    user_id = payload["sub"]
    today = datetime.now().strftime("%Y-%m-%d")

    target_steps = body.target_steps
    target_water_intake_ml = body.target_water_intake_ml

    try:
        # Check if today's tracking data exists
        check_result = (
            supabase_admin.table("tracking_data")
            .select("*")
            .eq("id", user_id)
            .eq("today_date", today)
            .execute()
        )

        if not check_result.data:
            raise HTTPException(
                status_code=400,
                detail="User today's tracking data not found in Supabase",
            )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=400, detail=f"User today's tracking data not found: {str(e)}"
        )

    try:
        # Update target tracking data
        supabase_admin.table("tracking_data").update(
            {
                "target_steps": target_steps,
                "target_water_intake_ml": target_water_intake_ml,
            }
        ).eq("id", user_id).eq("today_date", today).execute()

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to update user's target tracking data: {str(e)}",
        )


# ============================================================================
# APIs
# ============================================================================


@router.get("/email")
async def get_tracking_email(
    authorization: str = Header(...),
    start_date: Optional[str] = Query(None),
    end_date: Optional[str] = Query(None),
):
    """
    Get user's tracking data for a week (email authentication)

    Args:
        authorization (str): Authorization header (contains jwt token)
        start_date (str): Optional start date in YYYY-MM-DD format
        end_date (str): Optional end date in YYYY-MM-DD format

    Returns:
        List of tracking data records
    """
    payload = await verify_es256_token(authorization)

    return await get_tracking_data(payload, start_date, end_date)


@router.get("/google")
async def get_tracking_google(
    authorization: str = Header(...),
    start_date: Optional[str] = Query(None),
    end_date: Optional[str] = Query(None),
):
    """
    Get user's tracking data for a week (google authentication)

    Args:
        authorization (str): Authorization header (contains jwt token)
        start_date (str): Optional start date in YYYY-MM-DD format
        end_date (str): Optional end date in YYYY-MM-DD format

    Returns:
        List of tracking data records
    """
    payload = await verify_hs256_token(authorization)

    return await get_tracking_data(payload, start_date, end_date)


@router.get("/today/email")
async def get_today_tracking_email(authorization: str = Header(...)):
    """
    Get user's tracking data for today (email authentication)

    Args:
        authorization (str): Authorization header (contains jwt token)

    Returns:
        Today's tracking data record
    """
    payload = await verify_es256_token(authorization)

    return await get_today_tracking(payload)


@router.get("/today/google")
async def get_today_tracking_google(authorization: str = Header(...)):
    """
    Get user's tracking data for today (google authentication)

    Args:
        authorization (str): Authorization header (contains jwt token)

    Returns:
        Today's tracking data record
    """
    payload = await verify_hs256_token(authorization)

    return await get_today_tracking(payload)


@router.put("/today/email")
async def update_current_tracking_email(
    authorization: str = Header(...), body: UpdateCurrentTrackingRequest = Body(...)
):
    """
    Update user's current tracking data (email authentication)

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (UpdateCurrentTrackingRequest): Request body with current_steps (int) and current_water_intake_ml (int)

    Returns:
        Success message
    """
    payload = await verify_es256_token(authorization)
    await update_current_tracking(payload, body)

    return {"Current tracking data updated successfully"}


@router.put("/today/google")
async def update_current_tracking_google(
    authorization: str = Header(...), body: UpdateCurrentTrackingRequest = Body(...)
):
    """
    Update user's current tracking data (google authentication)

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (UpdateCurrentTrackingRequest): Request body with current_steps (int) and current_water_intake_ml (int)

    Returns:
        Success message
    """
    payload = await verify_hs256_token(authorization)
    await update_current_tracking(payload, body)

    return {"Current tracking data updated successfully"}


@router.put("/today/targets/email")
async def update_target_tracking_email(
    authorization: str = Header(...), body: UpdateTargetTrackingRequest = Body(...)
):
    """
    Update user's target tracking data (email authentication)

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (UpdateTargetTrackingRequest): Request body with target_steps (int) and target_water_intake_ml (int)

    Returns:
        Success message
    """
    payload = await verify_es256_token(authorization)
    await update_target_tracking(payload, body)

    return {"Target tracking data updated successfully"}


@router.put("/today/targets/google")
async def update_target_tracking_google(
    authorization: str = Header(...), body: UpdateTargetTrackingRequest = Body(...)
):
    """
    Update user's target tracking data (google authentication)

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (UpdateTargetTrackingRequest): Request body with target_steps (int) and target_water_intake_ml (int)

    Returns:
        Success message
    """
    payload = await verify_hs256_token(authorization)
    await update_target_tracking(payload, body)

    return {"Target tracking data updated successfully"}
