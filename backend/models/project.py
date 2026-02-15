"""Project model"""
from enum import Enum
from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class ProjectStatus(str, Enum):
    PLANNING = "planning"
    IN_PROGRESS = "in_progress"
    ON_HOLD = "on_hold"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class Project(BaseModel):
    id: str
    name: str
    description: Optional[str] = None
    status: ProjectStatus
    foreman_id: str
    location: str
    start_date: datetime
    end_date: Optional[datetime] = None
    budget: Optional[float] = None
    client_name: Optional[str] = None
    assigned_workers: list[str] = []

    class Config:
        json_schema_extra = {
            "example": {
                "id": "proj_001",
                "name": "Office Building Rewiring",
                "description": "Complete electrical rewiring of 5-story office building",
                "status": "in_progress",
                "foreman_id": "user_003",
                "location": "123 Main St, Downtown",
                "start_date": "2024-02-01T08:00:00",
                "end_date": "2024-04-30T17:00:00",
                "budget": 150000.00,
                "client_name": "ABC Corporation",
                "assigned_workers": ["user_001", "user_002", "user_004"]
            }
        }
