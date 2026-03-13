import uuid
from typing import List
from models import RouteRequest, TripOption, TripSegment, TravelMode
from logic.strategies.base import TravelStrategy
from logic.maps import GoogleMapsService
from logic.pricing import PricingService

class DrivingStrategy(TravelStrategy):
    
    async def generate_options(self, req: RouteRequest) -> List[TripOption]:
        routes = await GoogleMapsService.get_drive_routes(req.origin, req.destination)

        options = []
        for route_data in routes:
            gas_price = PricingService.get_gas_price_along_route(
                route_data["polyline"],
                state_code=req.origin.state,
            )
            gallons = route_data["distance_miles"] / req.user_profile.car_mpg
            fuel_cost = gallons * gas_price
            emissions_kg = PricingService.get_drive_emissions_kg(gallons)

            segment = TripSegment(
                mode=TravelMode.DRIVE,
                start_point=req.origin,
                end_point=req.destination,
                duration_minutes=route_data["duration_minutes"],
                distance_miles=route_data["distance_miles"],
                cost_usd=round(fuel_cost, 2),
                details=f"Drive {route_data['distance_miles']:.0f} miles",
                polyline=route_data["polyline"]
            )

            options.append(TripOption(
                route_id=str(uuid.uuid4()),
                total_cost=segment.cost_usd,
                total_duration_minutes=segment.duration_minutes,
                total_emissions_kg=round(emissions_kg, 1),
                segments=[segment],
                debug_reason="Standard Drive"
            ))

        return options
