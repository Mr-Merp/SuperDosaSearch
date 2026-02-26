from models import GeoPoint
from pymongo import MongoClient

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

    @staticmethod
    def get_flight_data(origin, dest):
        # MOCK: In prod, call Skyscanner/Amadeus
        return {"price": 250.0, "duration_minutes": 300}
