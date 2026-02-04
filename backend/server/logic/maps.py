import math
from models import GeoPoint

class GoogleMapsService:
    @staticmethod
    def get_drive_route(origin: GeoPoint, dest: GeoPoint):
        # placeholder for Google Maps API call
        dist = math.hypot(dest.lat - origin.lat, dest.lng - origin.lng) * 69
        return { 
            "distance_miles": dist,
            "duration_minutes": int(dist),
            "polyline": "encoded_poly_string_example" # flutter needs this for route display
        }
