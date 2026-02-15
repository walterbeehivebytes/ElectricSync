# ElectricSync Backend

FastAPI-based backend for the ElectricSync mobile application.

## Features

- RESTful API for managing users, projects, and tasks
- Mock data for development (no database required yet)
- Role-based user management (Electrician, Journeyman, Foreman)
- Project tracking and task assignment
- FastAPI automatic documentation

## Setup

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Run the development server:
```bash
python main.py
```

The API will be available at `http://localhost:8000`

## API Documentation

Once the server is running, visit:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## API Endpoints

### Users
- `GET /api/users/` - List all users
- `GET /api/users/{user_id}` - Get user by ID
- `GET /api/users/role/{role}` - Get users by role (electrician, journeyman, foreman)

### Projects
- `GET /api/projects/` - List all projects
- `GET /api/projects/{project_id}` - Get project by ID
- `GET /api/projects/status/{status}` - Get projects by status

### Tasks
- `GET /api/tasks/` - List all tasks
- `GET /api/tasks/{task_id}` - Get task by ID
- `GET /api/tasks/project/{project_id}` - Get tasks by project
- `GET /api/tasks/user/{user_id}` - Get tasks by user
- `GET /api/tasks/status/{status}` - Get tasks by status

## Mock Data

The backend currently uses mock data located in `mock_data/`:
- `users_mock.py` - Sample electricians, journeymen, and foremen
- `projects_mock.py` - Sample construction projects
- `tasks_mock.py` - Sample tasks with assignments and status

## Project Structure

```
backend/
├── api/              # API route handlers
│   ├── users.py
│   ├── projects.py
│   └── tasks.py
├── models/           # Pydantic data models
│   ├── user.py
│   ├── project.py
│   └── task.py
├── mock_data/        # Mock data for development
│   ├── users_mock.py
│   ├── projects_mock.py
│   └── tasks_mock.py
├── services/         # Business logic (future)
├── main.py           # Application entry point
└── requirements.txt  # Python dependencies
```

## Next Steps

- Add authentication and authorization
- Implement database integration (PostgreSQL/MongoDB)
- Add POST/PUT/DELETE endpoints for CRUD operations
- Add file upload for documents/photos
- Implement time tracking
- Add material inventory management
