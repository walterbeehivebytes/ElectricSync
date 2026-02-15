"""Mock project data"""
from datetime import datetime
from models.project import Project, ProjectStatus

MOCK_PROJECTS = [
    Project(
        id="proj_001",
        name="Downtown Office Building Rewiring",
        description="Complete electrical rewiring of 5-story office building including main panel upgrade",
        status=ProjectStatus.IN_PROGRESS,
        foreman_id="user_003",
        location="123 Main St, Downtown",
        start_date=datetime(2024, 2, 1, 8, 0),
        end_date=datetime(2024, 4, 30, 17, 0),
        budget=150000.00,
        client_name="ABC Corporation",
        assigned_workers=["user_001", "user_002", "user_004"]
    ),
    Project(
        id="proj_002",
        name="Warehouse Lighting Upgrade",
        description="LED lighting installation throughout 50,000 sq ft warehouse facility",
        status=ProjectStatus.PLANNING,
        foreman_id="user_003",
        location="456 Industrial Blvd, West Side",
        start_date=datetime(2024, 3, 15, 8, 0),
        end_date=datetime(2024, 5, 15, 17, 0),
        budget=75000.00,
        client_name="XYZ Logistics",
        assigned_workers=["user_005"]
    ),
    Project(
        id="proj_003",
        name="Hospital Emergency Power System",
        description="Installation of backup generator and automatic transfer switches",
        status=ProjectStatus.IN_PROGRESS,
        foreman_id="user_003",
        location="789 Healthcare Dr, Medical District",
        start_date=datetime(2024, 1, 10, 7, 0),
        end_date=datetime(2024, 3, 30, 17, 0),
        budget=250000.00,
        client_name="City General Hospital",
        assigned_workers=["user_001", "user_005"]
    ),
    Project(
        id="proj_004",
        name="Retail Store Build-out",
        description="Complete electrical installation for new retail space",
        status=ProjectStatus.COMPLETED,
        foreman_id="user_003",
        location="321 Shopping Plaza, Eastside",
        start_date=datetime(2023, 11, 1, 8, 0),
        end_date=datetime(2024, 1, 15, 17, 0),
        budget=45000.00,
        client_name="Fashion Boutique Inc",
        assigned_workers=["user_002", "user_004"]
    ),
]


def get_all_projects():
    """Return all mock projects"""
    return MOCK_PROJECTS


def get_project_by_id(project_id: str):
    """Get a project by ID"""
    return next((project for project in MOCK_PROJECTS if project.id == project_id), None)


def get_projects_by_status(status: ProjectStatus):
    """Get all projects with a specific status"""
    return [project for project in MOCK_PROJECTS if project.status == status]
