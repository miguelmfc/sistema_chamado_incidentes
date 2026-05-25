from app.repositories.incident_repository import IncidentRepository
from app.services.message_service import MessageService

VALID_SEVERITIES = ['low', 'medium', 'high', 'critical']
VALID_STATUSES = ['open', 'in_progress', 'resolved', 'closed']

class IncidentService:

    def __init__(self):
        self.repository = IncidentRepository()
        self.message_service = MessageService()

    def get_all_incidents(self):
        return self.repository.find_all()

    def get_incident_by_id(self, incident_id):
        incident = self.repository.find_by_id(incident_id)
        if not incident:
            raise ValueError(f'Incident {incident_id} not found')
        return incident

    def create_incident(self, data):
        title = data.get('title', '').strip()
        description = data.get('description', '').strip()
        severity = data.get('severity', 'medium').lower()
        reporter_name = data.get('reporter_name', '').strip()

        if not title or not description or not reporter_name:
            raise ValueError('title, description and reporter_name are required')
        if severity not in VALID_SEVERITIES:
            raise ValueError(f'severity must be one of {VALID_SEVERITIES}')

        incident = self.repository.create(title, description, severity, reporter_name)
        self.message_service.publish_incident_created(incident)  # ← NOVO
        return incident

    def update_incident_status(self, incident_id, data):
        status = data.get('status', '').lower()
        analyst_name = data.get('analyst_name')

        if status not in VALID_STATUSES:
            raise ValueError(f'status must be one of {VALID_STATUSES}')

        incident = self.repository.find_by_id(incident_id)
        if not incident:
            raise ValueError(f'Incident {incident_id} not found')

        incident = self.repository.update_status(incident_id, status, analyst_name)
        self.message_service.publish_incident_updated(incident)  # ← NOVO
        return incident

    def delete_incident(self, incident_id):
        incident = self.repository.find_by_id(incident_id)
        if not incident:
            raise ValueError(f'Incident {incident_id} not found')
        return self.repository.delete(incident_id)