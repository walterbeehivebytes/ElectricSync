"""Mock user data"""
from models.user import User, UserRole

MOCK_USERS = [
    User(
        id="user_001",
        email="john.smith@example.com",
        name="John Smith",
        role=UserRole.JOURNEYMAN,
        phone="+1-555-0101",
        license_number="JM-12345",
        years_experience=5,
        certifications=["OSHA-30", "Arc Flash Safety", "NFPA 70E"],
        active=True
    ),
    User(
        id="user_002",
        email="sarah.johnson@example.com",
        name="Sarah Johnson",
        role=UserRole.ELECTRICIAN,
        phone="+1-555-0102",
        license_number="EL-67890",
        years_experience=2,
        certifications=["OSHA-10"],
        active=True
    ),
    User(
        id="user_003",
        email="mike.williams@example.com",
        name="Mike Williams",
        role=UserRole.FOREMAN,
        phone="+1-555-0103",
        license_number="FM-54321",
        years_experience=12,
        certifications=["OSHA-30", "Master Electrician", "Project Management", "NFPA 70E"],
        active=True
    ),
    User(
        id="user_004",
        email="david.brown@example.com",
        name="David Brown",
        role=UserRole.ELECTRICIAN,
        phone="+1-555-0104",
        license_number="EL-11223",
        years_experience=3,
        certifications=["OSHA-10", "First Aid/CPR"],
        active=True
    ),
    User(
        id="user_005",
        email="lisa.martinez@example.com",
        name="Lisa Martinez",
        role=UserRole.JOURNEYMAN,
        phone="+1-555-0105",
        license_number="JM-98765",
        years_experience=7,
        certifications=["OSHA-30", "Arc Flash Safety", "Confined Space"],
        active=True
    ),
]


def get_all_users():
    """Return all mock users"""
    return MOCK_USERS


def get_user_by_id(user_id: str):
    """Get a user by ID"""
    return next((user for user in MOCK_USERS if user.id == user_id), None)


def get_users_by_role(role: UserRole):
    """Get all users with a specific role"""
    return [user for user in MOCK_USERS if user.role == role]
