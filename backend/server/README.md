# SuperDosaSearch Backend

Flask-based REST API server for the SuperDosaSearch trip planning application.

## Features
- Route search and optimization
- Cost vs speed preference ranking
- Integration with flight and maps APIs
- RESTful API endpoints

## Project Structure
```
server/
  ├── main.py            # Flask app entry point
  ├── routes.py          # API routes and endpoints
  ├── models.py          # Data models
  ├── requirements.txt   # Python dependencies
  └── services/          # External API integrations
      ├── flight_api.py  # Flight search integration
      ├── maps_api.py    # Maps and routing integration
      └── ranking.py     # Route ranking algorithm
```

## Getting Started

### Prerequisites
- Python 3.8+
- pip or conda

### Installation
```bash
pip install -r requirements.txt
```

### Running
```bash
python main.py
```
Server will run at `http://localhost:5000`

## API Endpoints

### POST /api/search
Search for travel routes
```json
{
  "from": "New York",
  "to": "Los Angeles",
  "budget": 500
}
```

### GET /api/health
Health check endpoint

## Development
- API docs available at `/api/docs`
- Debug mode enabled by default

## Contributing
See ../docs/ for more information
