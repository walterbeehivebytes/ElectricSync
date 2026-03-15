"""Task API endpoints"""
from fastapi import APIRouter, HTTPException, Depends
from models.task import Task, TaskStatus
from models.user import User, UserRole
from mock_data.tasks_mock import (
    get_all_tasks,
    get_task_by_id,
    get_tasks_by_project,
    get_tasks_by_user,
    get_tasks_by_status,
)
from services.auth_service import get_current_user, require_roles

router = APIRouter()


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


@router.get("/{task_id}", response_model=Task)
async def get_task(task_id: str, current_user: User = Depends(get_current_user)):
    """Get a specific task — any authenticated role."""
    task = get_task_by_id(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task
