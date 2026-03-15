"""Authentication endpoints"""
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, EmailStr
from models.user import User, UserRole
from mock_data.users_mock import MOCK_USERS, get_user_by_email
from services.auth_service import authenticate_user, create_access_token, register_user, hash_password

router = APIRouter()


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class SignupRequest(BaseModel):
    email: EmailStr
    password: str
    name: str
    role: UserRole


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: User


@router.post("/login", response_model=TokenResponse)
async def login(body: LoginRequest):
    user = authenticate_user(body.email, body.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )
    token = create_access_token({"sub": user.email, "role": user.role.value})
    return TokenResponse(access_token=token, user=user)


@router.post("/signup", response_model=TokenResponse, status_code=201)
async def signup(body: SignupRequest):
    if get_user_by_email(body.email):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists",
        )
    # Register password
    registered = register_user(body.email, body.password)
    if not registered:
        raise HTTPException(status_code=409, detail="Email already registered")

    # Create and persist the new user in mock store
    new_id = f"user_{len(MOCK_USERS) + 1:03d}"
    new_user = User(id=new_id, email=body.email, name=body.name, role=body.role)
    MOCK_USERS.append(new_user)

    token = create_access_token({"sub": new_user.email, "role": new_user.role.value})
    return TokenResponse(access_token=token, user=new_user)


@router.get("/me", response_model=User)
async def get_me(token: str = None):
    """Convenience endpoint — returns current user from token."""
    from fastapi import Depends
    from services.auth_service import get_current_user
    # This is handled via dependency injection in protected routes.
    # For direct use, clients should decode the JWT or call a protected endpoint.
    raise HTTPException(status_code=501, detail="Use Authorization header with a protected endpoint")
