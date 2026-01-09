from pydantic import BaseModel
from typing import Optional


class MedicationRequest(BaseModel):
    name: str
    dose_value: int
    dose_unit: str
    frequency_type: str
    frequency_time: str
    start_date: str
    durations: Optional[int] = None
    notes: Optional[str] = None
