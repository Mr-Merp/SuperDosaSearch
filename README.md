# SuperDosaSearch (Findosa)

A **personalized**, **context‑aware** travel **recommendation** system for finding optimal ways to travel. Taking into account driving 🚘, public transporation 🚉, and flights 🛫!

## Overview 🔎
SuperDosaSearch is a **full‑stack** travel planning prototype that compares travel routes (driving, public transporation, flight) and ranks them by total cost vs time tradeoffs, and visualizes the journey on an interactive map. The frontend is built in **Flutter** and the backend uses **FastAPI**.

## Main Features 📌
- Search routes from an origin/destination, with budget and preference options
- Ranking travel options based on estimated cost + time value model
- An interactive map, visualizing the destination and origin
- Personalized recommendations based on travel preferences (driving over flight, public transporation over driving, etc.)

## Tech Stack 🧱
- Frontend: Flutter, flutter_map, OpenStreetMap tiles
- Backend: FastAPI (Python)
- APIs: Google Geocoding & Directions, OilPriceAPI (state averages)
- Data: airports.geojson

## Entry Points 🚀
- `frontend/super_dosa_app/` = Flutter app
- `backend/server/`         = FastAPI backend

## Setup ⚙️
- **Prerequisites**
  - Python 3.12+
  - Flutter SDK
- **Environment Variables**
  - Create a local config file at: `backend/server/config.env`
- **Add**
  ```env
  GOOGLE_API_KEY=your_key_here
  OILPRICE_API_KEY=your_key_here
  ```
    - GOOGLE_API_KEY is required for geocoding and driving route data.
    - OILPRICE_API_KEY enables state‑average gas pricing; if missing, a fallback price is used.
  
- **Backend**
  ```env
  cd backend/server
  python3 -m venv .venv
  source .venv/bin/activate
  pip install -r requirements.txt
  uvicorn main:app --reload --port 5000
- **Frontend**
  ```env
  cd frontend/super_dosa_app
  flutter pub get
  flutter run -d chrome

## Contributors 🤝
- Owen Yang (https://github.com/Mr-Merp)
- Lokesh Sharma (https://github.com/lakeshoree)
- Pranav Gonuguntla (https://github.com/pranavgonuguntla)
- Alejandro Olivares-Lopez (https://github.com/OLIVARA5)
 




