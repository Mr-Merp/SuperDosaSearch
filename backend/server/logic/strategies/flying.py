import uuid
from typing import List
from models import RouteRequest, TripOption, TripSegment, TravelMode, GeoPoint
from logic.strategies.base import TravelStrategy
from logic.maps import GoogleMapsService
from logic.pricing import PricingService

class FlyingStrategy(TravelStrategy):
    
    async def generate_options(self, req: RouteRequest) -> List[TripOption]:
        options = []
        
        origins = PricingService.find_nearby_airports(req.origin)
        dests = PricingService.find_nearby_airports(req.destination)
        
        for start_apt in origins:
            for end_apt in dests:
                
                flight = PricingService.get_flight_data(start_apt["code"], end_apt["code"])
                rental_cost = PricingService.get_rental_car_price(end_apt["code"])
                
                drive_to_apt = GoogleMapsService.get_drive_route(
                    req.origin, GeoPoint(lat=start_apt['lat'], lng=start_apt['lng'])
                )
                
                # driving to airport
                seg_1 = TripSegment(
                    mode=TravelMode.DRIVE,
                    start_point=req.origin,
                    end_point=GeoPoint(lat=start_apt['lat'], lng=start_apt['lng']),
                    duration_minutes=drive_to_apt["duration_minutes"],
                    distance_miles=drive_to_apt["distance_miles"],
                    cost_usd=(drive_to_apt["distance_miles"] / req.user_profile.car_mpg) * 3.50,
                    details=f"Drive to {start_apt['code']}",
                    polyline=drive_to_apt["polyline"]
                )

                # flight start
                flight_buffer = 120 
                
                seg_2 = TripSegment(
                    mode=TravelMode.FLY,
                    start_point=GeoPoint(lat=start_apt['lat'], lng=start_apt['lng']),
                    end_point=GeoPoint(lat=end_apt['lat'], lng=end_apt['lng']),
                    duration_minutes=flight["duration_minutes"] + flight_buffer,
                    distance_miles=0, # distance doesn't matter for user effort
                    cost_usd=flight["price"],
                    details=f"Flight {start_apt['code']} -> {end_apt['code']}",
                    polyline="" # no need for flight polyline
                )
                
                # back to driving
                drive_to_dest = GoogleMapsService.get_drive_route(
                    GeoPoint(lat=end_apt['lat'], lng=end_apt['lng']), req.destination
                )
                
                seg_3 = TripSegment(
                    mode=TravelMode.DRIVE,
                    start_point=GeoPoint(lat=end_apt['lat'], lng=end_apt['lng']),
                    end_point=req.destination,
                    duration_minutes=drive_to_dest["duration_minutes"],
                    distance_miles=drive_to_dest["distance_miles"],
                    cost_usd=rental_cost,
                    details=f"Rental to Destination",
                    polyline=drive_to_dest["polyline"]
                )
                
                total_cost = seg_1.cost_usd + seg_2.cost_usd + seg_3.cost_usd
                total_time = seg_1.duration_minutes + seg_2.duration_minutes + seg_3.duration_minutes
                
                options.append(TripOption(
                    route_id=str(uuid.uuid4()),
                    total_cost=round(total_cost, 2),
                    total_duration_minutes=int(total_time),
                    segments=[seg_1, seg_2, seg_3],
                    debug_reason=f"Fly via {start_apt['code']}"
                ))
                
        return options