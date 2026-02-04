from models import GeoPoint

class PricingService:
    @staticmethod
    def get_gas_price_along_route(polyline: str):
        # TODO: H3 Spatial Index Query
        return 3.50

    @staticmethod
    def find_nearby_airports(location: GeoPoint):
        # MOCK: In prod, query your DB for airports within 100 miles
        return [
            {"code": "LAX", "lat": 33.94, "lng": -118.40},
            {"code": "JFK", "lat": 40.64, "lng": -73.77}
        ]

    @staticmethod
    def get_flight_data(origin, dest):
        # MOCK: In prod, call Skyscanner/Amadeus
        return {"price": 250.0, "duration_minutes": 300}

    @staticmethod
    def get_rental_car_price(code):
        # MOCK: In prod, call Kayak
        return 65.0