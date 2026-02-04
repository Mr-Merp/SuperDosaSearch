import uuid
from typing import List
from models import RouteRequest, TripOption, TripSegment, TravelMode
from logic.strategies.base import TravelStrategy
from logic.maps import GoogleMapsService
from logic.pricing import PricingService

class DrivingStrategy(TravelStrategy):
    
    async def generate_options(self, req: RouteRequest) -> List[TripOption]:
        route_data = GoogleMapsService.get_drive_route(req.origin, req.destination)
        
        # gas prices by miles 
        gas_price = PricingService.get_gas_price_along_route(route_data["polyline"])
        gallons = route_data["distance_miles"] / req.user_profile.car_mpg 
        fuel_cost = gallons * gas_price
        
        segment = TripSegment(
            mode=TravelMode.DRIVE,
            start_point=req.origin,
            end_point=req.destination,
            duration_minutes=route_data["duration_minutes"],
            distance_miles=route_data["distance_miles"],
            cost_usd=round(fuel_cost, 2),
            details=f"Drive {route_data['distance_miles']:.0f} miles",
            polyline=route_data["polyline"] # Send to Flutter
        )
        
        return [TripOption(
            route_id=str(uuid.uuid4()),
            total_cost=segment.cost_usd,
            total_duration_minutes=segment.duration_minutes,
            segments=[segment],
            debug_reason="Standard Drive"
        )]