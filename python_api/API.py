from flask import Flask
from flask_cors import CORS
from auth_routes import auth_bp

app = Flask(__name__)
CORS(app)

app.register_blueprint(auth_bp, url_prefix='/api/auth')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)