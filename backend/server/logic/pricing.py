import json
import math
import os

from models import GeoPoint

try:
    from oilpriceapi import OilPriceAPI
except Exception:
    OilPriceAPI = None

NEARBY_AIRPORT_RADIUS_METERS = 64374
_STATE_FUEL_CACHE = {}
_KG_CO2_PER_GALLON_GASOLINE = 8.89
_KG_CO2_PER_FLIGHT_MILE = 0.2

class PricingService:
    @staticmethod
    def get_gas_price_along_route(polyline: str, state_code: str | None = None):
        return PricingService.get_gas_price_for_state(state_code)

    @staticmethod
    def get_gas_price_for_state(state_code: str | None):
        if not state_code:
            return 3.50
        key = state_code.upper()
        if key in _STATE_FUEL_CACHE:
            return _STATE_FUEL_CACHE[key]
        api_key = os.getenv("OILPRICE_API_KEY")
        if not api_key or OilPriceAPI is None:
            return 3.50
        try:
            client = OilPriceAPI(api_key)
            data = client.diesel_prices.get_regional(state=key)
            price = float(data.get("price", 3.50))
            _STATE_FUEL_CACHE[key] = price
            return price
        except Exception:
            return 3.50

    @staticmethod
    def find_nearby_airports(location: GeoPoint, radius_meters: int = NEARBY_AIRPORT_RADIUS_METERS, limit: int = 5):
        path = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", "airports.geojson"))
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        features = data.get("features", [])
        results = []
        radius_miles = radius_meters / 1609.34
        for feat in features:
            coords = (feat.get("geometry") or {}).get("coordinates") or []
            if len(coords) != 2:
                continue
            lon, lat = coords
            dist = _haversine_miles(location.lat, location.lng, lat, lon)
            if dist <= radius_miles:
                props = feat.get("properties") or {}
                apt_type = props.get("type")
                if apt_type not in {"large_airport", "medium_airport"}:
                    continue
                if props.get("scheduled_service") is not True:
                    continue
                results.append({
                    "iata_code": props.get("iata_code"),
                    "icao_code": props.get("icao_code"),
                    "name": props.get("name"),
                    "lat": lat,
                    "lng": lon,
                    "type": props.get("type"),
                    "_dist": dist,
                })
        results.sort(key=lambda x: x["_dist"])
        large = [r for r in results if r.get("type") == "large_airport"]
        medium = [r for r in results if r.get("type") == "medium_airport"]
        ordered = large + medium

        out = []
        for r in ordered:
            if len(out) >= limit:
                break
            if r.get("iata_code"):
                out.append({k: v for k, v in r.items() if k != "_dist"})
        return out

    @staticmethod
    def get_flight_data(
        origin_code,
        dest_code,
        origin_lat,
        origin_lng,
        dest_lat,
        dest_lng,
        origin_type: str | None = None,
        dest_type: str | None = None,
    ):
        distance_miles = _haversine_miles(origin_lat, origin_lng, dest_lat, dest_lng)
        base_fare = 60.0
        per_mile = 0.12
        price = base_fare + (per_mile * distance_miles)
        if origin_type == "large_airport" or dest_type == "large_airport":
            price *= 1.45
        elif origin_type == "medium_airport" or dest_type == "medium_airport":
            price *= 1.30
        price = max(80.0, min(price, 700.0))

        avg_speed_mph = 500.0
        flight_minutes = int((distance_miles / avg_speed_mph) * 60)
        duration_minutes = max(45, flight_minutes + 60)

        return {"price": round(price, 2), "duration_minutes": duration_minutes}

    @staticmethod
    def get_drive_emissions_kg(gallons: float) -> float:
        return gallons * _KG_CO2_PER_GALLON_GASOLINE

    @staticmethod
    def get_flight_emissions_kg(origin: GeoPoint, dest: GeoPoint) -> float:
        miles = _haversine_miles(origin.lat, origin.lng, dest.lat, dest.lng)
        return miles * _KG_CO2_PER_FLIGHT_MILE


def _haversine_miles(lat1, lon1, lat2, lon2):
    r = 3958.8
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
    return 2 * r * math.atan2(math.sqrt(a), math.sqrt(1 - a))
