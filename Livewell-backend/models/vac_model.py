from pydantic import BaseModel
from typing import Optional


class VaccinationRequest(BaseModel):
    name: str
    dose_date: str
    next_dose_date: Optional[str] = None
    location: Optional[str] = None
    notes: Optional[str] = None
