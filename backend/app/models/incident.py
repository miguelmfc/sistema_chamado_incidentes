class Incident:
    def __init__(self, id, title, description, severity, status,
                 reporter_name, analyst_name, created_at, updated_at):
        self.id = id
        self.title = title
        self.description = description
        self.severity = severity
        self.status = status
        self.reporter_name = reporter_name
        self.analyst_name = analyst_name
        self.created_at = created_at
        self.updated_at = updated_at

    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'severity': self.severity,
            'status': self.status,
            'reporter_name': self.reporter_name,
            'analyst_name': self.analyst_name,
            'created_at': self.created_at,
            'updated_at': self.updated_at
        }