class User:
    def __init__(self, id, name, email, role, created_at):
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.created_at = created_at

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'role': self.role,
            'created_at': self.created_at
        }