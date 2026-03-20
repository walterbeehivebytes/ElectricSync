"""User API endpoints"""
from fastapi import APIRouter, HTTPException, Depends
from models.user import User, UserRole
from mock_data.users_mock import get_all_users, get_user_by_id, get_users_by_role
from services.auth_service import get_current_user, require_roles

router = APIRouter()


@router.get("/", response_model=list[User])
async def list_users(current_user: User = Depends(get_current_user)):
    """Get all users — any authenticated role."""
    return get_all_users()


@router.get("/me", response_model=User)
async def get_me(current_user: User = Depends(get_current_user)):
    """Get the currently authenticated user."""
    return current_user


@router.get("/{user_id}", response_model=User)
async def get_user(user_id: str, current_user: User = Depends(get_current_user)):
    """Get a specific user by ID — any authenticated role."""
    user = get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.get("/role/{role}", response_model=list[User])
async def list_users_by_role(
    role: UserRole,
    current_user: User = Depends(
        require_roles(UserRole.PROJECT_MANAGER, UserRole.SITE_MANAGER, UserRole.TEAM_LEAD)
    ),
):
    """Get all users with a specific role — PM, SM, and TL only."""
    return get_users_by_role(role)
