"""Mock task data"""
from datetime import datetime
from models.task import Task, TaskStatus, TaskPriority

MOCK_TASKS = [
    # user_001 = Diana Chen (PM), user_002 = James Park (SM)
    # user_003 = Carmen Ortiz (Team Lead), user_004 = Mike Rodriguez (Team Member)
    Task(
        id="task_001",
        project_id="proj_001",
        title="Install main electrical panel",
        description="Install 400A main electrical panel on ground floor",
        status=TaskStatus.IN_PROGRESS,
        priority=TaskPriority.HIGH,
        assigned_to="user_004",
        team_lead_id="user_003",
        created_by="user_001",
        created_at=datetime(2024, 2, 1, 8, 0),
        due_date=datetime(2024, 2, 5, 17, 0),
        estimated_hours=16.0,
        actual_hours=10.0,
        materials_needed=["400A Panel", "Conduit", "Wire", "Panel cover"],
        safety_requirements=["Arc Flash PPE", "Lock-out Tag-out", "Hard Hat"]
    ),
    Task(
        id="task_002",
        project_id="proj_001",
        title="Run conduit for floors 2-3",
        description="Install EMT conduit runs for second and third floors",
        status=TaskStatus.TODO,
        priority=TaskPriority.MEDIUM,
        assigned_to=None,
        team_lead_id=None,
        created_by="user_001",
        created_at=datetime(2024, 2, 1, 8, 0),
        due_date=datetime(2024, 2, 12, 17, 0),
        estimated_hours=24.0,
        materials_needed=["EMT Conduit", "Connectors", "Straps", "Junction boxes"],
        safety_requirements=["Fall Protection", "Hard Hat", "Safety Glasses"]
    ),
    Task(
        id="task_003",
        project_id="proj_001",
        title="Pull wire for floors 1-2",
        description="Pull 12 AWG and 10 AWG wire through installed conduit",
        status=TaskStatus.TODO,
        priority=TaskPriority.MEDIUM,
        assigned_to=None,
        team_lead_id=None,
        created_by="user_001",
        created_at=datetime(2024, 2, 1, 8, 0),
        due_date=datetime(2024, 2, 15, 17, 0),
        estimated_hours=20.0,
        materials_needed=["12 AWG wire", "10 AWG wire", "Wire pulling lubricant"],
        safety_requirements=["Gloves", "Back support belt", "Hard Hat"]
    ),
    Task(
        id="task_004",
        project_id="proj_003",
        title="Install generator transfer switch",
        description="Install and wire automatic transfer switch for emergency generator",
        status=TaskStatus.REVIEW,
        priority=TaskPriority.URGENT,
        assigned_to="user_003",
        team_lead_id="user_003",
        created_by="user_001",
        created_at=datetime(2024, 1, 10, 7, 0),
        due_date=datetime(2024, 2, 1, 17, 0),
        estimated_hours=32.0,
        actual_hours=30.0,
        materials_needed=["Transfer switch", "Control panel", "Wire", "Conduit"],
        safety_requirements=["Arc Flash PPE", "Lock-out Tag-out", "Confined Space permit"]
    ),
    Task(
        id="task_005",
        project_id="proj_003",
        title="Test emergency power system",
        description="Perform load testing and failover testing of emergency power system",
        status=TaskStatus.TODO,
        priority=TaskPriority.HIGH,
        assigned_to=None,
        team_lead_id=None,
        created_by="user_001",
        created_at=datetime(2024, 1, 10, 7, 0),
        due_date=datetime(2024, 3, 15, 17, 0),
        estimated_hours=16.0,
        materials_needed=["Load bank", "Testing equipment", "Meters"],
        safety_requirements=["Arc Flash PPE", "Lock-out Tag-out", "Communication equipment"]
    ),
    Task(
        id="task_006",
        project_id="proj_002",
        title="Survey warehouse lighting requirements",
        description="Conduct site survey and lighting calculations for warehouse",
        status=TaskStatus.IN_PROGRESS,
        priority=TaskPriority.HIGH,
        assigned_to="user_003",
        team_lead_id="user_003",
        created_by="user_002",
        created_at=datetime(2024, 2, 10, 8, 0),
        due_date=datetime(2024, 2, 20, 17, 0),
        estimated_hours=8.0,
        actual_hours=4.0,
        materials_needed=["Light meter", "Measuring tape", "Laser measure"],
        safety_requirements=["Hard Hat", "Safety Vest", "Lift certification"]
    ),
    Task(
        id="task_007",
        project_id="proj_001",
        title="Install outlets and switches - Floor 1",
        description="Install all receptacles and switches on first floor",
        status=TaskStatus.TODO,
        priority=TaskPriority.MEDIUM,
        assigned_to="user_004",
        team_lead_id="user_003",
        created_by="user_002",
        created_at=datetime(2024, 2, 1, 8, 0),
        due_date=datetime(2024, 2, 18, 17, 0),
        estimated_hours=12.0,
        materials_needed=["Outlets", "Switches", "Cover plates", "Wire nuts"],
        safety_requirements=["Safety Glasses", "Hard Hat", "Voltage tester"]
    ),
    Task(
        id="task_008",
        project_id="proj_003",
        title="Install emergency lighting - Floor 3",
        description="Mount and wire emergency egress lighting fixtures on third floor per code",
        status=TaskStatus.TODO,
        priority=TaskPriority.HIGH,
        assigned_to="user_004",
        team_lead_id="user_003",
        created_by="user_001",
        created_at=datetime(2024, 1, 10, 7, 0),
        due_date=datetime(2024, 3, 10, 17, 0),
        estimated_hours=8.0,
        materials_needed=["Emergency fixtures", "Battery packs", "Wire", "Conduit"],
        safety_requirements=["Arc Flash PPE", "Hard Hat", "Fall Protection"]
    ),
    Task(
        id="task_009",
        project_id="proj_001",
        title="Terminate wire at panel B",
        description="Terminate all branch circuit wires at sub-panel B, label breakers",
        status=TaskStatus.TODO,
        priority=TaskPriority.URGENT,
        assigned_to="user_004",
        team_lead_id="user_003",
        created_by="user_001",
        created_at=datetime(2024, 2, 1, 8, 0),
        due_date=datetime(2024, 2, 8, 17, 0),
        estimated_hours=6.0,
        materials_needed=["Wire lugs", "Breakers", "Label tape", "Torque screwdriver"],
        safety_requirements=["Arc Flash PPE", "Lock-out Tag-out", "Voltage tester"]
    ),
]


def get_all_tasks():
    """Return all mock tasks"""
    return MOCK_TASKS


def get_task_by_id(task_id: str):
    """Get a task by ID"""
    return next((task for task in MOCK_TASKS if task.id == task_id), None)


def get_tasks_by_project(project_id: str):
    """Get all tasks for a specific project"""
    return [task for task in MOCK_TASKS if task.project_id == project_id]


def get_tasks_by_user(user_id: str):
    """Get all tasks assigned to a specific user"""
    return [task for task in MOCK_TASKS if task.assigned_to == user_id]


def get_tasks_by_status(status: TaskStatus):
    """Get all tasks with a specific status"""
    return [task for task in MOCK_TASKS if task.status == status]


def get_tasks_by_team_lead(lead_id: str):
    """Get all tasks where this user is the responsible team lead."""
    return [task for task in MOCK_TASKS if task.team_lead_id == lead_id]


def update_task(task_id: str, updates: dict):
    """Apply partial updates to a task in-place. Returns updated task or None."""
    for i, task in enumerate(MOCK_TASKS):
        if task.id == task_id:
            updated = task.model_copy(update=updates)
            MOCK_TASKS[i] = updated
            return updated
    return None


def create_task(data: dict, created_by: str) -> Task:
    """Append a new task to the in-memory list and return it."""
    import uuid
    new_task = Task(
        id=f"task_{uuid.uuid4().hex[:8]}",
        created_by=created_by,
        created_at=datetime.utcnow(),
        status=TaskStatus.TODO,
        **data,
    )
    MOCK_TASKS.append(new_task)
    return new_task
