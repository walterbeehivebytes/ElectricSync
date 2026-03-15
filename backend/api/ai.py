"""AI endpoints — work order generation and crew dispatch recommendations."""
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from models.user import User, UserRole
from services.auth_service import get_current_user, require_roles
from services.ai_service import generate_work_order, dispatch_recommend

router = APIRouter()


class WorkOrderRequest(BaseModel):
    description: str


class DispatchTask(BaseModel):
    id: str
    title: str
    priority: str
    description: str = ""


class DispatchCrewMember(BaseModel):
    id: str
    name: str
    role: str
    active_tasks: int = 0


class DispatchRequest(BaseModel):
    tasks: list[DispatchTask]
    crew: list[DispatchCrewMember]


@router.post("/generate-work-order")
async def generate_work_order_endpoint(
    body: WorkOrderRequest,
    current_user: User = Depends(
        require_roles(UserRole.PROJECT_MANAGER, UserRole.SITE_MANAGER)
    ),
):
    """
    PM or SM describes work in plain text — Claude returns a structured work order.
    """
    if not body.description.strip():
        raise HTTPException(status_code=400, detail="Description cannot be empty")
    try:
        result = generate_work_order(body.description)
        return result
    except ValueError as e:
        raise HTTPException(status_code=503, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"AI generation failed: {str(e)}. You can still create the work order manually.",
        )


@router.post("/dispatch-recommend")
async def dispatch_recommend_endpoint(
    body: DispatchRequest,
    current_user: User = Depends(
        require_roles(UserRole.PROJECT_MANAGER, UserRole.SITE_MANAGER)
    ),
):
    """
    SM provides unassigned tasks and crew — Claude recommends optimal assignments.
    """
    if not body.tasks:
        raise HTTPException(status_code=400, detail="No tasks provided")
    if not body.crew:
        raise HTTPException(status_code=400, detail="No crew provided")
    try:
        tasks = [t.model_dump() for t in body.tasks]
        crew = [c.model_dump() for c in body.crew]
        result = dispatch_recommend(tasks, crew)
        return result
    except ValueError as e:
        raise HTTPException(status_code=503, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"AI recommendation failed: {str(e)}. You can still assign tasks manually.",
        )
