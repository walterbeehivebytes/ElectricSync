"""User model"""
from enum import Enum
from pydantic import BaseModel, EmailStr
from typing import Optional


class UserRole(str, Enum):
    ELECTRICIAN = "electrician"
    JOURNEYMAN = "journeyman"
    FOREMAN = "foreman"


class User(BaseModel):
    id: str
    email: EmailStr
    name: str
    role: UserRole
    phone: Optional[str] = None
    license_number: Optional[str] = None
    years_experience: Optional[int] = None
    certifications: list[str] = []
    active: bool = True

    class Config:
        json_schema_extra = {
            "example": {
                "id": "user_001",
                "email": "john.doe@example.com",
                "name": "John Doe",
                "role": "journeyman",
                "phone": "+1-555-0100",
                "license_number": "JM-12345",
                "years_experience": 5,
                "certifications": ["OSHA-30", "Arc Flash Safety"],
                "active": True
            }
        }
