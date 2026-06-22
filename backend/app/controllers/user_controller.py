from flask import Blueprint, jsonify, request
from app.services.user_service import UserService

user_bp = Blueprint('users', __name__)
service = UserService()

def success(data, status_code=200):
    return jsonify({'success': True, 'data': data}), status_code

def error(message, status_code=400):
    return jsonify({'success': False, 'error': message}), status_code

# POST /api/auth/register
@user_bp.route('/auth/register', methods=['POST'])
def register():
    data = request.get_json()
    if not data:
        return error('JSON body required')
    try:
        user = service.register(data)
        return success(user.to_dict(), 201)
    except ValueError as e:
        return error(str(e))

# POST /api/auth/login
@user_bp.route('/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data:
        return error('JSON body required')
    try:
        user = service.login(data)
        return success(user.to_dict())
    except ValueError as e:
        return error(str(e), 401)