import json
import math
import os

from models import GeoPoint
from pymongo import MongoClient
from pymongo.errors import PyMongoError

_client = MongoClient("mongodb://localhost:27017")
_airports = _client["cs125"]["airports"]

NEARBY_AIRPORT_RADIUS_METERS = 64374  # 40 miles

class PricingService:
    @staticmethod
    def get_gas_price_along_route(polyline: str):
        # TODO: H3 Spatial Index Query
        return 3.50

    @staticmethod
    def find_nearby_airports(location: GeoPoint, radius_meters: int = NEARBY_AIRPORT_RADIUS_METERS):
        try:
            cursor = _airports.find({
                "geometry": {
                    "$nearSphere": {
                        "$geometry": {
                            "type": "Point",
                            "coordinates": [location.lng, location.lat]
                        },
                        "$maxDistance": radius_meters
                    }
                }
            })
            return [
                {
                    "iata_code": doc["properties"].get("iata_code"),
                    "icao_code": doc["properties"].get("icao_code"),
                    "name": doc["properties"].get("name"),
                    "lat": doc["geometry"]["coordinates"][1],
                    "lng": doc["geometry"]["coordinates"][0],
                }
                for doc in cursor
            ]
        except PyMongoError:
            # Fallback to local GeoJSON when MongoDB isn't available.
            path = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", "airports.geojson"))
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
            features = data.get("features", [])
            results = []
            # Convert radius meters -> miles for haversine comparison
            radius_miles = radius_meters / 1609.34
            for feat in features:
                coords = (feat.get("geometry") or {}).get("coordinates") or []
                if len(coords) != 2:
                    continue
                lon, lat = coords
                if _haversine_miles(location.lat, location.lng, lat, lon) <= radius_miles:
                    props = feat.get("properties") or {}
                    results.append({
                        "iata_code": props.get("iata_code"),
                        "icao_code": props.get("icao_code"),
                        "name": props.get("name"),
                        "lat": lat,
                        "lng": lon,
                    })
            return results

    @staticmethod
    def get_flight_data(origin, dest):
        # MOCK: In prod, call Skyscanner/Amadeus
        return {"price": 250.0, "duration_minutes": 300}


def _haversine_miles(lat1, lon1, lat2, lon2):
    r = 3958.8
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
    return 2 * r * math.atan2(math.sqrt(a), math.sqrt(1 - a))
