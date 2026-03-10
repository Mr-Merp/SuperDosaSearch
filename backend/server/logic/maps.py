import os
import requests
from models import GeoPoint

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
DIRECTIONS_URL = "https://maps.googleapis.com/maps/api/directions/json"
GEOCODE_URL = "https://maps.googleapis.com/maps/api/geocode/json"

class GoogleMapsService:
    @staticmethod
    def geocode_address(address: str) -> GeoPoint:
        response = requests.get(GEOCODE_URL, params={
            "address": address,
            "key": GOOGLE_API_KEY,
        })
        response.raise_for_status()
        data = response.json()

        if data["status"] != "OK":
            raise ValueError(f"Geocoding API error: {data['status']}")

        location = data["results"][0]["geometry"]["location"]
        return GeoPoint(lat=location["lat"], lng=location["lng"], address=address)

    @staticmethod
    def get_drive_routes(origin: GeoPoint, dest: GeoPoint):
        response = requests.get(DIRECTIONS_URL, params={
            "origin": f"{origin.lat},{origin.lng}",
            "destination": f"{dest.lat},{dest.lng}",
            "mode": "driving",
            "alternatives": "true",
            "key": GOOGLE_API_KEY,
        })
        response.raise_for_status()
        data = response.json()

        if data["status"] != "OK":
            raise ValueError(f"Directions API error: {data['status']}")

        routes = []
        for route in data["routes"]:
            leg = route["legs"][0]
            routes.append({
                "distance_miles": leg["distance"]["value"] / 1609.34,
                "duration_minutes": int(leg["duration"]["value"] / 60),
                "polyline": route["overview_polyline"]["points"],
            })
        return routes
