from database import get_connection
from app.models.user import User

class UserRepository:

    def _row_to_user(self, row):
        return User(
            id=row['id'],
            name=row['name'],
            email=row['email'],
            role=row['role'],
            created_at=row['created_at']
        )

    def find_by_email(self, email):
        conn = get_connection()
        row = conn.execute(
            'SELECT * FROM users WHERE email = ?', (email,)
        ).fetchone()
        conn.close()
        return row

    def create(self, name, email, password, role='client'):
        conn = get_connection()
        try:
            cursor = conn.execute(
                'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)',
                (name, email, password, role)
            )
            conn.commit()
            user_id = cursor.lastrowid
            conn.close()
            row = self.find_by_email(email)
            return self._row_to_user(row)
        except Exception as e:
            conn.close()
            raise e