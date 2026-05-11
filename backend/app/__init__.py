from flask import Flask
from flask_cors import CORS
from database import init_db

def create_app():
    app = Flask(__name__)
    CORS(app)

    with app.app_context():
        init_db()

    from app.controllers.incident_controller import incident_bp
    app.register_blueprint(incident_bp, url_prefix='/api')

    return app