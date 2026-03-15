"""
ElectricSync Backend API
Main application entry point
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api import users, projects, tasks
from api import auth

app = FastAPI(
    title="ElectricSync API",
    description="Role-first job site coordination for electricians. PM → SM → Team Lead → Team Member.",
    version="0.2.0"
)

# Configure CORS for Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict to your domain in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Auth routes (public — no token required)
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])

# Protected routes (require valid JWT)
app.include_router(users.router, prefix="/api/users", tags=["users"])
app.include_router(projects.router, prefix="/api/projects", tags=["projects"])
app.include_router(tasks.router, prefix="/api/tasks", tags=["tasks"])


@app.get("/")
async def root():
    return {
        "message": "ElectricSync API",
        "version": "0.2.0",
        "status": "running",
        "auth": "POST /api/auth/login  |  POST /api/auth/signup",
        "docs": "/docs"
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
