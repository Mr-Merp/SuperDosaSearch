import os
import httpx
from models import GeoPoint

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
DIRECTIONS_URL = "https://maps.googleapis.com/maps/api/directions/json"
GEOCODE_URL = "https://maps.googleapis.com/maps/api/geocode/json"


class GoogleMapsService:
    @staticmethod
    async def geocode_address(address: str) -> GeoPoint:
        async with httpx.AsyncClient() as client:
            response = await client.get(GEOCODE_URL, params={
                "address": address,
                "key": GOOGLE_API_KEY,
            })
            response.raise_for_status()
            data = response.json()
        if data["status"] != "OK":
            raise ValueError(f"Geocoding API error: {data['status']}")
        result = data["results"][0]
        location = result["geometry"]["location"]
        state = None
        for comp in result.get("address_components", []):
            if "administrative_area_level_1" in comp.get("types", []):
                state = comp.get("short_name")
                break
        return GeoPoint(lat=location["lat"], lng=location["lng"], address=address, state=state)

    @staticmethod
    async def get_drive_routes(origin: GeoPoint, dest: GeoPoint):
        async with httpx.AsyncClient() as client:
            response = await client.get(DIRECTIONS_URL, params={
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
