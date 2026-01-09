from pydantic import BaseModel


class UpdateCurrentTrackingRequest(BaseModel):
    current_steps: int
    current_water_intake_ml: int


class UpdateTargetTrackingRequest(BaseModel):
    target_steps: int
    target_water_intake_ml: int
