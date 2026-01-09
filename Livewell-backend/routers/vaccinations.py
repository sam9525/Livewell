from fastapi import APIRouter, HTTPException, Header, Body
from pydantic import BaseModel
from utils.jwt_handler import verify_es256_token, verify_hs256_token
from dotenv import load_dotenv
from supabase import Client, create_client
import os
from datetime import datetime
from typing import Optional


router = APIRouter(prefix="/api/health/vaccinations", tags=["health"])


# ============================================================================
# Request Models
# ============================================================================


class VaccinationRequest(BaseModel):
    name: str
    dose_date: str
    next_dose_date: Optional[str] = None
    location: Optional[str] = None
    notes: Optional[str] = None


# Init supabase admin
url: str = os.getenv("SUPABASE_URL")
key: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
supabase_admin: Client = create_client(url, key)


# ============================================================================
# Functions for Vaccinations
# ============================================================================


async def get_all_vaccinations(payload: dict):
    """
    Get all vaccinations for a user

    Args:
        payload (dict): JWT payload (contains user's information)

    Returns:
        List of vaccination records
    """
    user_id = payload["sub"]

    try:
        result = (
            supabase_admin.table("vaccinations")
            .select("*")
            .eq("id", user_id)
            .order("created_at", desc=True)
            .execute()
        )

        return result.data

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to get vaccination list: {str(e)}"
        )


async def get_vaccination_by_id(payload: dict, vac_id: str):
    """
    Get a specific vaccination by ID

    Args:
        payload (dict): JWT payload (contains user's information)
        vac_id (str): Vaccination ID

    Returns:
        Vaccination record
    """
    user_id = payload["sub"]

    try:
        result = (
            supabase_admin.table("vaccinations")
            .select("*")
            .eq("id", user_id)
            .eq("vac_id", vac_id)
            .execute()
        )

        if not result.data:
            raise HTTPException(status_code=404, detail="Vaccination not found")

        return result.data[0]

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to get vaccination: {str(e)}"
        )


async def create_vaccination(payload: dict, body: VaccinationRequest):
    """
    Create a new vaccination

    Args:
        payload (dict): JWT payload (contains user's information)
        body (VaccinationRequest): Vaccination data

    Returns:
        Success message
    """
    user_id = payload["sub"]

    try:
        vaccination_data = {
            "name": body.name,
            "dose_date": body.dose_date,
            "next_dose_date": body.next_dose_date,
            "location": body.location,
            "notes": body.notes,
            "id": user_id,
        }

        supabase_admin.table("vaccinations").insert(vaccination_data).execute()

        return {"Vaccination added successfully"}

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to add vaccination: {str(e)}"
        )


async def update_vaccination(payload: dict, vac_id: str, body: VaccinationRequest):
    """
    Update a vaccination

    Args:
        payload (dict): JWT payload (contains user's information)
        vac_id (str): Vaccination ID
        body (VaccinationRequest): Updated vaccination data

    Returns:
        Success message
    """
    user_id = payload["sub"]

    try:
        # Check if vaccination exists and belongs to user
        check_result = (
            supabase_admin.table("vaccinations")
            .select("*")
            .eq("id", user_id)
            .eq("vac_id", vac_id)
            .execute()
        )

        if not check_result.data:
            raise HTTPException(status_code=404, detail="Vaccination not found")

        # Update the vaccination
        update_data = {
            "name": body.name,
            "dose_date": body.dose_date,
            "next_dose_date": body.next_dose_date,
            "location": body.location,
            "notes": body.notes,
            "updated_at": datetime.now().isoformat(),
        }

        supabase_admin.table("vaccinations").update(update_data).eq(
            "vac_id", vac_id
        ).eq("id", user_id).execute()

        return {"Vaccination updated successfully"}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to update vaccination: {str(e)}"
        )


async def delete_vaccination(payload: dict, vac_id: str):
    """
    Delete a vaccination

    Args:
        payload (dict): JWT payload (contains user's information)
        vac_id (str): Vaccination ID

    Returns:
        Success message
    """
    user_id = payload["sub"]

    try:
        # Check if vaccination exists and belongs to user
        check_result = (
            supabase_admin.table("vaccinations")
            .select("*")
            .eq("id", user_id)
            .eq("vac_id", vac_id)
            .execute()
        )

        if not check_result.data:
            raise HTTPException(status_code=404, detail="Vaccination not found")

        # Delete the vaccination
        supabase_admin.table("vaccinations").delete().eq("vac_id", vac_id).eq(
            "id", user_id
        ).execute()

        return {"Vaccination deleted successfully"}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to delete vaccination: {str(e)}"
        )


# ============================================================================
# Vaccination APIs - Email Authentication
# ============================================================================


@router.get("/email")
async def get_vaccinations_email(authorization: str = Header(...)):
    """
    Get all vaccinations for user (email authentication)

    Args:
        authorization (str): Authorization header (contains jwt token)

    Returns:
        List of vaccination records
    """
    payload = await verify_es256_token(authorization)

    return await get_all_vaccinations(payload)


@router.post("/email")
async def create_vaccination_email(
    authorization: str = Header(...), body: VaccinationRequest = Body(...)
):
    """
    Create a new vaccination (email authentication)

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (VaccinationRequest): Vaccination data

    Returns:
        Success message
    """
    payload = await verify_es256_token(authorization)

    return await create_vaccination(payload, body)


@router.get("/email/{vac_id}")
async def get_vaccination_email(vac_id: str, authorization: str = Header(...)):
    """
    Get a specific vaccination by ID (email authentication)

    Args:
        vac_id (str): Vaccination ID
        authorization (str): Authorization header (contains jwt token)

    Returns:
        Vaccination record
    """
    payload = await verify_es256_token(authorization)

    return await get_vaccination_by_id(payload, vac_id)


@router.put("/email/{vac_id}")
async def update_vaccination_email(
    vac_id: str, authorization: str = Header(...), body: VaccinationRequest = Body(...)
):
    """
    Update a specific vaccination (email authentication)

    Args:
        vac_id (str): Vaccination ID
        authorization (str): Authorization header (contains jwt token)
        body (VaccinationRequest): Updated vaccination data

    Returns:
        Success message
    """
    payload = await verify_es256_token(authorization)

    return await update_vaccination(payload, vac_id, body)


@router.delete("/email/{vac_id}")
async def delete_vaccination_email(vac_id: str, authorization: str = Header(...)):
    """
    Delete a specific vaccination (email authentication)

    Args:
        vac_id (str): Vaccination ID
        authorization (str): Authorization header (contains jwt token)

    Returns:
        Success message
    """
    payload = await verify_es256_token(authorization)

    return await delete_vaccination(payload, vac_id)


# ============================================================================
# Vaccination APIs - Google Authentication
# ============================================================================


@router.get("/google")
async def get_vaccinations_google(authorization: str = Header(...)):
    """
    Get all vaccinations for user (google authentication)

    Args:
        authorization (str): Authorization header (contains jwt token)

    Returns:
        List of vaccination records
    """
    payload = await verify_hs256_token(authorization)

    return await get_all_vaccinations(payload)


@router.post("/google")
async def create_vaccination_google(
    authorization: str = Header(...), body: VaccinationRequest = Body(...)
):
    """
    Create a new vaccination (google authentication)

    Args:
        authorization (str): Authorization header (contains jwt token)
        body (VaccinationRequest): Vaccination data

    Returns:
        Success message
    """
    payload = await verify_hs256_token(authorization)

    return await create_vaccination(payload, body)


@router.get("/google/{vac_id}")
async def get_vaccination_google(vac_id: str, authorization: str = Header(...)):
    """
    Get a specific vaccination by ID (google authentication)

    Args:
        vac_id (str): Vaccination ID
        authorization (str): Authorization header (contains jwt token)

    Returns:
        Vaccination record
    """
    payload = await verify_hs256_token(authorization)

    return await get_vaccination_by_id(payload, vac_id)


@router.put("/google/{vac_id}")
async def update_vaccination_google(
    vac_id: str, authorization: str = Header(...), body: VaccinationRequest = Body(...)
):
    """
    Update a specific vaccination (google authentication)

    Args:
        vac_id (str): Vaccination ID
        authorization (str): Authorization header (contains jwt token)
        body (VaccinationRequest): Updated vaccination data

    Returns:
        Success message
    """
    payload = await verify_hs256_token(authorization)

    return await update_vaccination(payload, vac_id, body)


@router.delete("/google/{vac_id}")
async def delete_vaccination_google(vac_id: str, authorization: str = Header(...)):
    """
    Delete a specific vaccination (google authentication)

    Args:
        vac_id (str): Vaccination ID
        authorization (str): Authorization header (contains jwt token)

    Returns:
        Success message
    """
    payload = await verify_hs256_token(authorization)

    return await delete_vaccination(payload, vac_id)
