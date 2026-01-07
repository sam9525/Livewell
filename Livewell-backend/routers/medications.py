from fastapi import APIRouter, HTTPException, Header, Body
from pydantic import BaseModel
from utils.jwt_handler import verify_es256_token, verify_hs256_token
from dotenv import load_dotenv
from supabase import Client, create_client
import os
from datetime import datetime
from typing import Optional


router = APIRouter(prefix="/api/health/medications", tags=["health"])


# ============================================================================
# Request Models
# ============================================================================


class MedicationRequest(BaseModel):
    name: str
    dose_value: int
    dose_unit: str
    frequency_type: str
    frequency_time: str
    start_date: str
    durations: Optional[int] = None
    notes: Optional[str] = None


# Init supabase admin
url: str = os.getenv("SUPABASE_URL")
key: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
supabase_admin: Client = create_client(url, key)


# ============================================================================
# Functions for Medications
# ============================================================================


async def get_all_medications(payload: dict):
    """
    Get all medications for a user

    Args:
        payload (dict): JWT payload (contains user's information)

    Returns:
        List of medication records
    """
    user_id = payload["sub"]

    try:
        result = (
            supabase_admin.table("medications")
            .select("*")
            .eq("id", user_id)
            .order("created_at", desc=True)
            .execute()
        )

        return result.data

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to get medication list: {str(e)}"
        )


async def get_medication_by_id(payload: dict, med_id: str):
    """
    Get a specific medication by ID

    Args:
        payload (dict): JWT payload (contains user's information)
        med_id (str): Medication ID

    Returns:
        Medication record
    """
    user_id = payload["sub"]

    try:
        result = (
            supabase_admin.table("medications")
            .select("*")
            .eq("id", user_id)
            .eq("med_id", med_id)
            .execute()
        )

        if not result.data:
            raise HTTPException(status_code=404, detail="Medication not found")

        return result.data[0]

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to get medication: {str(e)}"
        )


async def create_medication(payload: dict, body: MedicationRequest):
    """
    Create a new medication

    Args:
        payload (dict): JWT payload (contains user's information)
        body (MedicationRequest): Medication data

    Returns:
        Success message
    """
    user_id = payload["sub"]

    try:
        medication_data = {
            "name": body.name,
            "dose_value": body.dose_value,
            "dose_unit": body.dose_unit,
            "frequency_type": body.frequency_type,
            "frequency_time": body.frequency_time,
            "start_date": body.start_date,
            "durations": body.durations,
            "notes": body.notes,
            "id": user_id,
        }

        supabase_admin.table("medications").insert(medication_data).execute()

        return {"Medication added successfully"}

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to add medication: {str(e)}, body: {body}"
        )


async def update_medication(payload: dict, med_id: str, body: MedicationRequest):
    """
    Update a medication

    Args:
        payload (dict): JWT payload (contains user's information)
        med_id (str): Medication ID
        body (MedicationRequest): Updated medication data

    Returns:
        Success message
    """
    user_id = payload["sub"]

    try:
        # Check if medication exists and belongs to user
        check_result = (
            supabase_admin.table("medications")
            .select("*")
            .eq("id", user_id)
            .eq("med_id", med_id)
            .execute()
        )

        if not check_result.data:
            raise HTTPException(status_code=404, detail="Medication not found")

        # Update the medication
        update_data = {
            "name": body.name,
            "dose_value": body.dose_value,
            "dose_unit": body.dose_unit,
            "frequency_type": body.frequency_type,
            "frequency_time": body.frequency_time,
            "start_date": body.start_date,
            "durations": body.durations,
            "notes": body.notes,
        }

        supabase_admin.table("medications").update(update_data).eq("med_id", med_id).eq(
            "id", user_id
        ).execute()

        return {"Medication updated successfully"}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to update medication: {str(e)}"
        )


async def delete_medication(payload: dict, med_id: str):
    """
    Delete a medication

    Args:
        payload (dict): JWT payload (contains user's information)
        med_id (str): Medication ID

    Returns:
        Success message
    """
    user_id = payload["sub"]

    try:
        # Check if medication exists and belongs to user
        check_result = (
            supabase_admin.table("medications")
            .select("*")
            .eq("id", user_id)
            .eq("med_id", med_id)
            .execute()
        )

        if not check_result.data:
            raise HTTPException(status_code=404, detail="Medication not found")

        # Delete the medication
        supabase_admin.table("medications").delete().eq("med_id", med_id).eq(
            "id", user_id
        ).execute()

        return {"Medication deleted successfully"}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to delete medication: {str(e)}"
        )


# ============================================================================
# Medication APIs - Email Authentication
# ============================================================================


@router.get("/email")
async def get_medications_email(authorization: str = Header(...)):
    """
    Get all medications for user (email authentication)

    Args:
        authorization (str): Authorization header (contains jwt token)

    Returns:
        List of medication records
    """
    payload = await verify_es256_token(authorization)

    return await get_all_medications(payload)


@router.post("/email")
async def create_medication_email(
    authorization: str = Header(...), body: MedicationRequest = Body(...)
):
    """
    Create a new medication (email authentication)

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (MedicationRequest): Medication data

    Returns:
        Success message
    """
    payload = await verify_es256_token(authorization)

    return await create_medication(payload, body)


@router.get("/email/{med_id}")
async def get_medication_email(med_id: str, authorization: str = Header(...)):
    """
    Get a specific medication by ID (email authentication)

    Args:
        med_id (str): Medication ID
        authorization (str): Authorization header (contains jwt token)

    Returns:
        Medication record
    """
    payload = await verify_es256_token(authorization)

    return await get_medication_by_id(payload, med_id)


@router.put("/email/{med_id}")
async def update_medication_email(
    med_id: str, authorization: str = Header(...), body: MedicationRequest = Body(...)
):
    """
    Update a specific medication (email authentication)

    Args:
        med_id (str): Medication ID
        authorization (str): Authorization header (contains jwt token)
        body (MedicationRequest): Updated medication data

    Returns:
        Success message
    """
    payload = await verify_es256_token(authorization)

    return await update_medication(payload, med_id, body)


@router.delete("/email/{med_id}")
async def delete_medication_email(med_id: str, authorization: str = Header(...)):
    """
    Delete a specific medication (email authentication)

    Args:
        med_id (str): Medication ID
        authorization (str): Authorization header (contains jwt token)

    Returns:
        Success message
    """
    payload = await verify_es256_token(authorization)

    return await delete_medication(payload, med_id)


# ============================================================================
# Medication APIs - Google Authentication
# ============================================================================


@router.get("/google")
async def get_medications_google(authorization: str = Header(...)):
    """
    Get all medications for user (google authentication)

    Args:
        authorization (str): Authorization header (contains jwt token)

    Returns:
        List of medication records
    """
    payload = await verify_hs256_token(authorization)

    return await get_all_medications(payload)


@router.post("/google")
async def create_medication_google(
    authorization: str = Header(...), body: MedicationRequest = Body(...)
):
    """
    Create a new medication (google authentication)

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (MedicationRequest): Medication data

    Returns:
        Success message
    """
    payload = await verify_hs256_token(authorization)

    return await create_medication(payload, body)


@router.get("/google/{med_id}")
async def get_medication_google(med_id: str, authorization: str = Header(...)):
    """
    Get a specific medication by ID (google authentication)

    Args:
        med_id (str): Medication ID
        authorization (str): Authorization header (contains jwt token)

    Returns:
        Medication record
    """
    payload = await verify_hs256_token(authorization)

    return await get_medication_by_id(payload, med_id)


@router.put("/google/{med_id}")
async def update_medication_google(
    med_id: str, authorization: str = Header(...), body: MedicationRequest = Body(...)
):
    """
    Update a specific medication (google authentication)

    Args:
        med_id (str): Medication ID
        authorization (str): Authorization header (contains jwt token)
        body (MedicationRequest): Updated medication data

    Returns:
        Success message
    """
    payload = await verify_hs256_token(authorization)

    return await update_medication(payload, med_id, body)


@router.delete("/google/{med_id}")
async def delete_medication_google(med_id: str, authorization: str = Header(...)):
    """
    Delete a specific medication (google authentication)

    Args:
        med_id (str): Medication ID
        authorization (str): Authorization header (contains jwt token)

    Returns:
        Success message
    """
    payload = await verify_hs256_token(authorization)

    return await delete_medication(payload, med_id)
