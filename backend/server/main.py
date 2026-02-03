"""
SuperDosaSearch Backend API Server
Main entry point for the Flask application
"""
from flask import Flask
from routes import api_routes

app = Flask(__name__)

# Register blueprints
app.register_blueprint(api_routes.bp)

if __name__ == '__main__':
    app.run(debug=True, host='localhost', port=5000)
