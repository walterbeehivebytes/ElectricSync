"""Task API endpoints"""
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional
from models.task import Task, TaskStatus, TaskPriority
from models.user import User, UserRole
from mock_data.tasks_mock import (
    get_all_tasks,
    get_task_by_id,
    get_tasks_by_project,
    get_tasks_by_user,
    get_tasks_by_status,
    get_tasks_by_team_lead,
    create_task,
    update_task,
)
from services.auth_service import get_current_user, require_roles


class TaskCreate(BaseModel):
    project_id: str
    title: str
    description: Optional[str] = None
    priority: TaskPriority = TaskPriority.MEDIUM
    materials_needed: list[str] = []
    safety_requirements: list[str] = []
    estimated_hours: Optional[float] = None


class TaskUpdate(BaseModel):
    assigned_to: Optional[str] = None
    team_lead_id: Optional[str] = None
    description: Optional[str] = None
    status: Optional[TaskStatus] = None
    priority: Optional[TaskPriority] = None


router = APIRouter()


@router.post("/", response_model=Task, status_code=201)
async def create_task_endpoint(
    body: TaskCreate,
    current_user: User = Depends(
        require_roles(UserRole.PROJECT_MANAGER, UserRole.SITE_MANAGER, UserRole.TEAM_LEAD)
    ),
):
    """Create a new task — PM, SM, or TL."""
    data = body.model_dump()
    if current_user.role == UserRole.TEAM_LEAD:
        data['team_lead_id'] = current_user.id
        data['assigned_to'] = current_user.id
    return create_task(data, created_by=current_user.id)


@router.get("/", response_model=list[Task])
async def list_tasks(current_user: User = Depends(get_current_user)):
    """Get all tasks — any authenticated role."""
    return get_all_tasks()


@router.get("/my", response_model=list[Task])
async def list_my_tasks(current_user: User = Depends(get_current_user)):
    """Get tasks assigned to the current user."""
    return get_tasks_by_user(current_user.id)


@router.get("/status/{status}", response_model=list[Task])
async def list_tasks_by_status(
    status: TaskStatus,
    current_user: User = Depends(get_current_user),
):
    """Get tasks by status — any authenticated role."""
    return get_tasks_by_status(status)


@router.get("/project/{project_id}", response_model=list[Task])
async def list_tasks_by_project(
    project_id: str,
    current_user: User = Depends(get_current_user),
):
    """Get all tasks for a project — any authenticated role."""
    return get_tasks_by_project(project_id)


@router.get("/user/{user_id}", response_model=list[Task])
async def list_tasks_by_user(
    user_id: str,
    current_user: User = Depends(
        require_roles(UserRole.PROJECT_MANAGER, UserRole.SITE_MANAGER, UserRole.TEAM_LEAD)
    ),
):
    """Get tasks assigned to a specific user — PM, SM, TL only."""
    return get_tasks_by_user(user_id)


@router.get("/team/{lead_id}", response_model=list[Task])
async def list_tasks_by_team_lead(
    lead_id: str,
    current_user: User = Depends(get_current_user),
):
    """Get all tasks where lead_id is the responsible team lead."""
    return get_tasks_by_team_lead(lead_id)


@router.get("/{task_id}", response_model=Task)
async def get_task(task_id: str, current_user: User = Depends(get_current_user)):
    """Get a specific task — any authenticated role."""
    task = get_task_by_id(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task


@router.patch("/{task_id}", response_model=Task)
async def update_task_endpoint(
    task_id: str,
    body: TaskUpdate,
    current_user: User = Depends(get_current_user),
):
    """Partially update a task.
    - PM / SM / TL: can update any field.
    - Team Member: can only update status of tasks assigned to them.
    """
    task = get_task_by_id(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    if current_user.role == UserRole.TEAM_MEMBER:
        if task.assigned_to != current_user.id:
            raise HTTPException(status_code=403, detail="You can only update your own tasks")
        updates = body.model_dump(exclude_unset=True)
        allowed = {"status"}
        forbidden = set(updates.keys()) - allowed
        if forbidden:
            raise HTTPException(status_code=403, detail=f"Team members may only update: {allowed}")
    else:
        if current_user.role not in (
            UserRole.PROJECT_MANAGER, UserRole.SITE_MANAGER, UserRole.TEAM_LEAD
        ):
            raise HTTPException(status_code=403, detail="Insufficient permissions")
        updates = body.model_dump(exclude_unset=True)

    updated = update_task(task_id, updates)
    return updated
