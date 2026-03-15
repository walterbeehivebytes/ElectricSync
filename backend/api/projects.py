"""Project API endpoints"""
from fastapi import APIRouter, HTTPException, Depends
from models.project import Project, ProjectStatus
from models.user import User, UserRole
from mock_data.projects_mock import get_all_projects, get_project_by_id, get_projects_by_status
from services.auth_service import get_current_user, require_roles

router = APIRouter()


@router.get("/", response_model=list[Project])
async def list_projects(current_user: User = Depends(get_current_user)):
    """Get all projects — any authenticated role."""
    return get_all_projects()


@router.get("/status/{status}", response_model=list[Project])
async def list_projects_by_status(
    status: ProjectStatus,
    current_user: User = Depends(get_current_user),
):
    """Get projects by status — any authenticated role."""
    return get_projects_by_status(status)


@router.get("/{project_id}", response_model=Project)
async def get_project(project_id: str, current_user: User = Depends(get_current_user)):
    """Get a specific project — any authenticated role."""
    project = get_project_by_id(project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return project
