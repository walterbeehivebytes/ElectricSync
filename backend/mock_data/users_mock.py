"""Mock user data — matches frontend demo accounts"""
from models.user import User, UserRole

MOCK_USERS = [
    User(
        id="user_001",
        email="pm@esync.com",
        name="Diana Chen",
        role=UserRole.PROJECT_MANAGER,
        phone="+1-555-0101",
        license_number="PM-12345",
        years_experience=12,
        certifications=["OSHA-30", "PMP", "Master Electrician", "NFPA 70E"],
        active=True
    ),
    User(
        id="user_002",
        email="site@esync.com",
        name="James Park",
        role=UserRole.SITE_MANAGER,
        phone="+1-555-0102",
        license_number="SM-67890",
        years_experience=8,
        certifications=["OSHA-30", "Arc Flash Safety", "NFPA 70E"],
        active=True
    ),
    User(
        id="user_003",
        email="lead@esync.com",
        name="Carmen Ortiz",
        role=UserRole.TEAM_LEAD,
        phone="+1-555-0103",
        license_number="TL-54321",
        years_experience=6,
        certifications=["OSHA-30", "Journeyman Electrician", "Arc Flash Safety"],
        active=True
    ),
    User(
        id="user_004",
        email="member@esync.com",
        name="Mike Rodriguez",
        role=UserRole.TEAM_MEMBER,
        phone="+1-555-0104",
        license_number="TM-11223",
        years_experience=3,
        certifications=["OSHA-10", "First Aid/CPR"],
        active=True
    ),
]


def get_all_users():
    """Return all mock users"""
    return MOCK_USERS


def get_user_by_id(user_id: str):
    """Get a user by ID"""
    return next((user for user in MOCK_USERS if user.id == user_id), None)


def get_user_by_email(email: str):
    """Get a user by email"""
    return next((user for user in MOCK_USERS if user.email == email), None)


def get_users_by_role(role: UserRole):
    """Get all users with a specific role"""
    return [user for user in MOCK_USERS if user.role == role]
