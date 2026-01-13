from fastapi import APIRouter, Header, HTTPException, Query
from typing import Optional, List
from utils import init_supabase, verify_es256_token, verify_hs256_token
from models import LocalResource

router = APIRouter(prefix="/api/local-resources", tags=["local-resources"])

# Init supabase admin
supabase_admin = init_supabase()


# ============================================================================
# Functions
# ============================================================================


async def get_local_resources_list(postcode: str):
    """
    Get all local resources

    Args:
        postcode (str): Postcode

    Returns:
        list: List of local resources
    """
    try:
        response = (
            supabase_admin.table("local_resources")
            .select("*")
            .eq("postcode", postcode)
            .execute()
        )

        return response.data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============================================================================
# APIs
# ============================================================================


@router.get("/email", response_model=List[LocalResource])
async def get_local_resources_email(
    authorization: str = Header(...), postcode: str = Query(...)
):
    """
    Get all local resources for email user

    Args:
        authorization (str): Authorization header
        postcode (str): Postcode

    Returns:
        list: List of local resources
    """
    await verify_es256_token(authorization)

    return await get_local_resources_list(postcode)


@router.get("/google", response_model=List[LocalResource])
async def get_local_resources_google(
    authorization: str = Header(...), postcode: str = Query(...)
):
    """
    Get all local resources for google user

    Args:
        authorization (str): Authorization header
        postcode (str): Postcode

    Returns:
        list: List of local resources
    """
    await verify_hs256_token(authorization)

    return await get_local_resources_list(postcode)
