"""
API Routes for SuperDosaSearch Backend
Handles trip planning and route optimization
"""
from flask import Blueprint, request, jsonify

bp = Blueprint('api', __name__, url_prefix='/api')

@bp.route('/search', methods=['POST'])
def search_routes():
    """
    Search for optimal travel routes
    Request body: {
        'from': 'departure city',
        'to': 'destination city',
        'budget': maximum budget
    }
    """
    data = request.get_json()
    
    # TODO: Implement route search logic
    return jsonify({
        'routes': [
            {
                'title': 'Cheapest Route',
                'details': 'Bus → Flight → Train',
                'price': 120,
                'time': '7h 30m'
            },
            {
                'title': 'Fastest Route',
                'details': 'Direct Flight',
                'price': 280,
                'time': '2h 10m'
            }
        ]
    })

@bp.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'ok'})
