import hashlib
from app.repositories.user_repository import UserRepository

class UserService:

    def __init__(self):
        self.repository = UserRepository()

    def _hash_password(self, password):
        return hashlib.sha256(password.encode()).hexdigest()

    def register(self, data):
        name = data.get('name', '').strip()
        email = data.get('email', '').strip().lower()
        password = data.get('password', '')
        role = data.get('role', 'client')

        if not name or not email or not password:
            raise ValueError('name, email and password are required')
        if len(password) < 6:
            raise ValueError('password must be at least 6 characters')
        if '@' not in email:
            raise ValueError('invalid email')
        if role not in ['client', 'analyst']:
            raise ValueError('role must be client or analyst')

        existing = self.repository.find_by_email(email)
        if existing:
            raise ValueError('email already registered')

        hashed = self._hash_password(password)
        return self.repository.create(name, email, hashed, role)

    def login(self, data):
        email = data.get('email', '').strip().lower()
        password = data.get('password', '')

        if not email or not password:
            raise ValueError('email and password are required')

        row = self.repository.find_by_email(email)
        if not row:
            raise ValueError('invalid credentials')

        hashed = self._hash_password(password)
        if row['password'] != hashed:
            raise ValueError('invalid credentials')

        from app.models.user import User
        return User(
            id=row['id'],
            name=row['name'],
            email=row['email'],
            role=row['role'],
            created_at=row['created_at']
        )