"""JWT authentication utilities"""
import os
from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from models.user import User, UserRole
from mock_data.users_mock import get_user_by_email

SECRET_KEY = os.getenv("SECRET_KEY", "electricsync-dev-secret-change-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24  # 24 hours

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")

# In-memory password store for mock users (email → hashed password)
# All demo accounts use "password123"
_MOCK_PASSWORDS: dict[str, str] = {}


def _init_mock_passwords():
    """Pre-hash passwords for demo accounts on first use."""
    demo_password = hash_password("password123")
    for email in ["pm@esync.com", "site@esync.com", "lead@esync.com", "member@esync.com"]:
        _MOCK_PASSWORDS[email] = demo_password


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def authenticate_user(email: str, password: str) -> Optional[User]:
    if not _MOCK_PASSWORDS:
        _init_mock_passwords()
    user = get_user_by_email(email)
    if not user:
        return None
    stored_hash = _MOCK_PASSWORDS.get(email)
    if not stored_hash or not verify_password(password, stored_hash):
        return None
    return user


def register_user(email: str, password: str) -> bool:
    """Register a new password for an email. Returns False if already exists."""
    if not _MOCK_PASSWORDS:
        _init_mock_passwords()
    if email in _MOCK_PASSWORDS:
        return False
    _MOCK_PASSWORDS[email] = hash_password(password)
    return True


async def get_current_user(token: str = Depends(oauth2_scheme)) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid or expired token",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = get_user_by_email(email)
    if user is None:
        raise credentials_exception
    return user


def require_roles(*roles: UserRole):
    """Dependency factory: raises 403 if current user's role is not in allowed roles."""
    async def role_guard(current_user: User = Depends(get_current_user)) -> User:
        if current_user.role not in roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied. Required role(s): {[r.value for r in roles]}"
            )
        return current_user
    return role_guard
