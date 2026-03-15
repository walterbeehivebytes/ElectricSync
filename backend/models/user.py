"""User model"""
from enum import Enum
from pydantic import BaseModel, EmailStr
from typing import Optional


class UserRole(str, Enum):
    PROJECT_MANAGER = "project_manager"
    SITE_MANAGER = "site_manager"
    TEAM_LEAD = "team_lead"
    TEAM_MEMBER = "team_member"


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
                "email": "pm@esync.com",
                "name": "Diana Chen",
                "role": "project_manager",
                "phone": "+1-555-0101",
                "license_number": "PM-12345",
                "years_experience": 12,
                "certifications": ["OSHA-30", "PMP", "Master Electrician"],
                "active": True
            }
        }
