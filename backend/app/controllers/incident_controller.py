from flask import Blueprint, jsonify, request
from app.services.incident_service import IncidentService

incident_bp = Blueprint('incidents', __name__)
service = IncidentService()

def success(data, status_code=200):
    return jsonify({'success': True, 'data': data}), status_code

def error(message, status_code=400):
    return jsonify({'success': False, 'error': message}), status_code

# GET /api/incidents
@incident_bp.route('/incidents', methods=['GET'])
def list_incidents():
    incidents = service.get_all_incidents()
    return success([i.to_dict() for i in incidents])

# GET /api/incidents/<id>
@incident_bp.route('/incidents/<int:incident_id>', methods=['GET'])
def get_incident(incident_id):
    try:
        incident = service.get_incident_by_id(incident_id)
        return success(incident.to_dict())
    except ValueError as e:
        return error(str(e), 404)

# POST /api/incidents
@incident_bp.route('/incidents', methods=['POST'])
def create_incident():
    data = request.get_json()
    if not data:
        return error('JSON body required')
    try:
        incident = service.create_incident(data)
        return success(incident.to_dict(), 201)
    except ValueError as e:
        return error(str(e))

# PATCH /api/incidents/<id>/status
@incident_bp.route('/incidents/<int:incident_id>/status', methods=['PATCH'])
def update_status(incident_id):
    data = request.get_json()
    if not data:
        return error('JSON body required')
    try:
        incident = service.update_incident_status(incident_id, data)
        return success(incident.to_dict())
    except ValueError as e:
        return error(str(e))

# DELETE /api/incidents/<id>
@incident_bp.route('/incidents/<int:incident_id>', methods=['DELETE'])
def delete_incident(incident_id):
    try:
        service.delete_incident(incident_id)
        return success({'message': 'Incident deleted successfully'})
    except ValueError as e:
        return error(str(e), 404)