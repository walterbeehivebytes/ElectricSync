"""Task model"""
from enum import Enum
from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class TaskStatus(str, Enum):
    TODO = "todo"
    IN_PROGRESS = "in_progress"
    REVIEW = "review"
    COMPLETED = "completed"
    BLOCKED = "blocked"


class TaskPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"


class Task(BaseModel):
    id: str
    project_id: str
    title: str
    description: Optional[str] = None
    status: TaskStatus
    priority: TaskPriority
    assigned_to: Optional[str] = None
    team_lead_id: Optional[str] = None
    created_by: str
    created_at: datetime
    due_date: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    estimated_hours: Optional[float] = None
    actual_hours: Optional[float] = None
    materials_needed: list[str] = []
    safety_requirements: list[str] = []

    class Config:
        json_schema_extra = {
            "example": {
                "id": "task_001",
                "project_id": "proj_001",
                "title": "Install main electrical panel",
                "description": "Install 400A main electrical panel on ground floor",
                "status": "in_progress",
                "priority": "high",
                "assigned_to": "user_001",
                "created_by": "user_003",
                "created_at": "2024-02-01T08:00:00",
                "due_date": "2024-02-05T17:00:00",
                "estimated_hours": 16.0,
                "materials_needed": ["400A Panel", "Conduit", "Wire"],
                "safety_requirements": ["Arc Flash PPE", "Lock-out Tag-out"]
            }
        }
