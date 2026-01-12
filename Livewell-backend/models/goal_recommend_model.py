from pydantic import BaseModel, Field


class GoalDetails(BaseModel):
    target_water_intake_ml: str
    target_steps: str


class WeeklyGoal(BaseModel):
    weekly_goal: GoalDetails = Field(alias="Weekly Goal")


class RecommendationResponse(BaseModel):
    user_id: str
    device_token: str
    recommendation: WeeklyGoal
