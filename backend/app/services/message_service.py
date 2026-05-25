import json
from datetime import datetime
from messaging import publish, QUEUES

class MessageService:

    def publish_incident_created(self, incident):
        payload = {
            'event': 'incident.created',
            'timestamp': datetime.utcnow().isoformat(),
            'data': {
                'id': incident.id,
                'title': incident.title,
                'severity': incident.severity,
                'reporter_name': incident.reporter_name,
                'status': incident.status,
                'created_at': incident.created_at
            }
        }
        publish(QUEUES['incident_created'], json.dumps(payload))

    def publish_incident_updated(self, incident):
        payload = {
            'event': 'incident.status_updated',
            'timestamp': datetime.utcnow().isoformat(),
            'data': {
                'id': incident.id,
                'title': incident.title,
                'status': incident.status,
                'analyst_name': incident.analyst_name,
                'updated_at': incident.updated_at
            }
        }
        publish(QUEUES['incident_updated'], json.dumps(payload))