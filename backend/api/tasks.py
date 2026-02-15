"""Task API endpoints"""
from fastapi import APIRouter, HTTPException
from models.task import Task, TaskStatus
from mock_data.tasks_mock import (
    get_all_tasks,
    get_task_by_id,
    get_tasks_by_project,
    get_tasks_by_user,
    get_tasks_by_status
)

router = APIRouter()


@router.get("/", response_model=list[Task])
async def list_tasks():
    """Get all tasks"""
    return get_all_tasks()


@router.get("/{task_id}", response_model=Task)
async def get_task(task_id: str):
    """Get a specific task by ID"""
    task = get_task_by_id(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task


@router.get("/project/{project_id}", response_model=list[Task])
async def list_tasks_by_project(project_id: str):
    """Get all tasks for a specific project"""
    return get_tasks_by_project(project_id)


@router.get("/user/{user_id}", response_model=list[Task])
async def list_tasks_by_user(user_id: str):
    """Get all tasks assigned to a specific user"""
    return get_tasks_by_user(user_id)


@router.get("/status/{status}", response_model=list[Task])
async def list_tasks_by_status(status: TaskStatus):
    """Get all tasks with a specific status"""
    return get_tasks_by_status(status)
