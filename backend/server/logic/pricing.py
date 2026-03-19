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
        # Use state average fuel price as a simple proxy.
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
            # OilPriceAPI free tier provides diesel state averages; use as proxy.
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
                results.append({
                    "iata_code": props.get("iata_code"),
                    "icao_code": props.get("icao_code"),
                    "name": props.get("name"),
                    "lat": lat,
                    "lng": lon,
                    "_dist": dist,
                })
        results.sort(key=lambda x: x["_dist"])
        out = []
        for r in results:
            if len(out) >= limit:
                break
            if r.get("iata_code"):
                out.append({k: v for k, v in r.items() if k != "_dist"})
        return out

    @staticmethod
    def get_flight_data(origin, dest):
        # MOCK: In prod, call Skyscanner/Amadeus
        return {"price": 250.0, "duration_minutes": 300}

    @staticmethod
    def get_drive_emissions_kg(gallons: float) -> float:
        return gallons * _KG_CO2_PER_GALLON_GASOLINE

    @staticmethod
    def get_flight_emissions_kg(origin: GeoPoint, dest: GeoPoint) -> float:
        miles = _haversine_miles(origin.lat, origin.lng, dest.lat, dest.lng)
        return miles * _KG_CO2_PER_FLIGHT_MILE

    @staticmethod
    def get_ridehail_estimate(distance_miles: float, duration_minutes: int) -> float:
        base_fare = 3.0
        per_mile = 2.25
        per_minute = 0.35
        return round(base_fare + (distance_miles * per_mile) + (duration_minutes * per_minute), 2)


def _haversine_miles(lat1, lon1, lat2, lon2):
    r = 3958.8
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
    return 2 * r * math.atan2(math.sqrt(a), math.sqrt(1 - a))
