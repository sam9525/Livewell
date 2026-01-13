from fastapi import APIRouter, Header, HTTPException, Body
from utils import init_supabase, verify_es256_token, verify_hs256_token

router = APIRouter(prefix="/api/goal/recommendation", tags=["goal-recommendation"])

# Init supabase admin
supabase_admin = init_supabase()


# ============================================================================
# Functions
# ============================================================================


async def get_goal_recommendation(user_id: str):
    """
    Get goal recommendation for a user

    Args:
        user_id (str): User ID

    Returns:
        list: List of goal recommendations
    """
    try:
        response = (
            supabase_admin.table("goal_recommendations")
            .select("*")
            .eq("id", user_id)
            .execute()
        )

        return response.data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


async def update_goal_recommendation(recommend_id: str, body: dict):
    """
    Update goal recommendation

    Args:
        recommend_id (str): Goal Recommendation ID
        body (dict): {"already_set: TRUE"}
    """
    try:
        supabase_admin.table("goal_recommendations").update(body).eq(
            "recommend_id", recommend_id
        ).execute()

        return {"Goal recommendation updated successfully"}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============================================================================
# APIs
# ============================================================================


@router.get("/email")
async def get_goal_recommendation_email(authorization: str = Header(...)):
    """
    Get user's goal recommendation for email user

    Args:
        authorization (str): Authorization header

    Returns:
        list: List of goal recommendations
    """
    payload = await verify_es256_token(authorization)

    user_id = payload["sub"]

    return await get_goal_recommendation(user_id)


@router.get("/google")
async def get_goal_recommendation_google(authorization: str = Header(...)):
    """
    Get user's goal recommendation for google user

    Args:
        authorization (str): Authorization header

    Returns:
        list: List of goal recommendations
    """
    payload = await verify_hs256_token(authorization)

    user_id = payload["sub"]

    return await get_goal_recommendation(user_id)


@router.put("/email/{recommend_id}")
async def update_goal_recommendation_email(
    recommend_id: str, authorization: str = Header(...), body: dict = Body(...)
):
    """
    Update specific goal recommendation for email user

    Args:
        recommend_id (str): Goal Recommendation ID
        authorization (str): Authorization header
        body (dict): {"already_set: TRUE"}
    """
    await verify_es256_token(authorization)

    return await update_goal_recommendation(recommend_id, body)


@router.put("/google/{recommend_id}")
async def update_goal_recommendation_google(
    recommend_id: str, authorization: str = Header(...), body: dict = Body(...)
):
    """
    Update specific goal recommendation for google user

    Args:
        recommend_id (str): Goal Recommendation ID
        authorization (str): Authorization header
        body (dict): {"already_set: TRUE"}
    """
    await verify_hs256_token(authorization)

    return await update_goal_recommendation(recommend_id, body)
