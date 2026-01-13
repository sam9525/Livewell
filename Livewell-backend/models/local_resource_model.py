from pydantic import BaseModel
from typing import Optional


class LocalResource(BaseModel):
    id: str
    name: str
    category: str
    description: str
    address: str
    postcode: str
    contact_info: str
