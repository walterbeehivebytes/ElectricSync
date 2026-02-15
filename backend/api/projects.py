"""Project API endpoints"""
from fastapi import APIRouter, HTTPException
from models.project import Project, ProjectStatus
from mock_data.projects_mock import get_all_projects, get_project_by_id, get_projects_by_status

router = APIRouter()


@router.get("/", response_model=list[Project])
async def list_projects():
    """Get all projects"""
    return get_all_projects()


@router.get("/{project_id}", response_model=Project)
async def get_project(project_id: str):
    """Get a specific project by ID"""
    project = get_project_by_id(project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return project


@router.get("/status/{status}", response_model=list[Project])
async def list_projects_by_status(status: ProjectStatus):
    """Get all projects with a specific status"""
    return get_projects_by_status(status)
