"""User API endpoints"""
from fastapi import APIRouter, HTTPException
from models.user import User, UserRole
from mock_data.users_mock import get_all_users, get_user_by_id, get_users_by_role

router = APIRouter()


@router.get("/", response_model=list[User])
async def list_users():
    """Get all users"""
    return get_all_users()


@router.get("/{user_id}", response_model=User)
async def get_user(user_id: str):
    """Get a specific user by ID"""
    user = get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.get("/role/{role}", response_model=list[User])
async def list_users_by_role(role: UserRole):
    """Get all users with a specific role"""
    return get_users_by_role(role)
