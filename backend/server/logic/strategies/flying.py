import asyncio
import uuid
from typing import List
from models import RouteRequest, TripOption, TripSegment, TravelMode, GeoPoint
from logic.strategies.base import TravelStrategy
from logic.maps import GoogleMapsService
from logic.pricing import PricingService

MAX_AIRPORTS_PER_SIDE = 3


class FlyingStrategy(TravelStrategy):

    async def generate_options(self, req: RouteRequest) -> List[TripOption]:
        origins = PricingService.find_nearby_airports(req.origin, limit=MAX_AIRPORTS_PER_SIDE)
        dests = PricingService.find_nearby_airports(req.destination, limit=MAX_AIRPORTS_PER_SIDE)
        pairs = []
        for start_apt in origins:
            for end_apt in dests:
                start_code = start_apt.get("code") or start_apt.get("iata_code")
                end_code = end_apt.get("code") or end_apt.get("iata_code")
                if start_code and end_code:
                    pairs.append((start_apt, end_apt))

        if not pairs:
            return []

        to_airport_tasks = [
            GoogleMapsService.get_drive_routes(req.origin, GeoPoint(lat=s["lat"], lng=s["lng"]))
            for s, e in pairs
        ]
        from_airport_tasks = [
            GoogleMapsService.get_drive_routes(GeoPoint(lat=e["lat"], lng=e["lng"]), req.destination)
            for s, e in pairs
        ]
        to_results, from_results = await asyncio.gather(
            asyncio.gather(*to_airport_tasks),
            asyncio.gather(*from_airport_tasks),
        )

        origin_gas = PricingService.get_gas_price_for_state(req.origin.state)
        dest_gas = PricingService.get_gas_price_for_state(req.destination.state)
        options = []
        for i, (start_apt, end_apt) in enumerate(pairs):
            start_code = start_apt.get("code") or start_apt.get("iata_code")
            end_code = end_apt.get("code") or end_apt.get("iata_code")
            drive_to_apt_list = to_results[i]
            drive_to_dest_list = from_results[i]
            if not drive_to_apt_list or not drive_to_dest_list:
                continue
            drive_to_apt = drive_to_apt_list[0]
            drive_to_dest = drive_to_dest_list[0]
            flight = PricingService.get_flight_data(start_code, end_code)
            use_ridehail_for_last_leg = req.user_profile.include_ridehail_airport_leg
            last_leg_cost = (
                PricingService.get_ridehail_estimate(
                    drive_to_dest["distance_miles"],
                    drive_to_dest["duration_minutes"],
                )
                if use_ridehail_for_last_leg
                else (drive_to_dest["distance_miles"] / req.user_profile.car_mpg) * dest_gas
            )
            last_leg_details = (
                "Uber/Taxi to Destination"
                if use_ridehail_for_last_leg
                else "Rental to Destination"
            )

            seg_1 = TripSegment(
                mode=TravelMode.DRIVE,
                start_point=req.origin,
                end_point=GeoPoint(lat=start_apt["lat"], lng=start_apt["lng"]),
                duration_minutes=drive_to_apt["duration_minutes"],
                distance_miles=drive_to_apt["distance_miles"],
                cost_usd=(drive_to_apt["distance_miles"] / req.user_profile.car_mpg) * origin_gas,
                details=f"Drive to {start_code}",
                polyline=drive_to_apt["polyline"],
            )
            seg_2 = TripSegment(
                mode=TravelMode.FLY,
                start_point=GeoPoint(lat=start_apt["lat"], lng=start_apt["lng"]),
                end_point=GeoPoint(lat=end_apt["lat"], lng=end_apt["lng"]),
                duration_minutes=flight["duration_minutes"] + 120,
                distance_miles=0,
                cost_usd=flight["price"],
                details=f"Flight {start_code} -> {end_code}",
                polyline="",
            )
            seg_3 = TripSegment(
                mode=TravelMode.DRIVE,
                start_point=GeoPoint(lat=end_apt["lat"], lng=end_apt["lng"]),
                end_point=req.destination,
                duration_minutes=drive_to_dest["duration_minutes"],
                distance_miles=drive_to_dest["distance_miles"],
                cost_usd=last_leg_cost,
                details=last_leg_details,
                polyline=drive_to_dest["polyline"],
            )
            total_cost = seg_1.cost_usd + seg_2.cost_usd + seg_3.cost_usd
            total_time = seg_1.duration_minutes + seg_2.duration_minutes + seg_3.duration_minutes
            drive_gallons = (drive_to_apt["distance_miles"] + drive_to_dest["distance_miles"]) / req.user_profile.car_mpg
            drive_emissions = PricingService.get_drive_emissions_kg(drive_gallons)
            flight_emissions = PricingService.get_flight_emissions_kg(
                GeoPoint(lat=start_apt["lat"], lng=start_apt["lng"]),
                GeoPoint(lat=end_apt["lat"], lng=end_apt["lng"]),
            )
            total_emissions = drive_emissions + flight_emissions
            options.append(
                TripOption(
                    route_id=str(uuid.uuid4()),
                    total_cost=round(total_cost, 2),
                    total_duration_minutes=int(total_time),
                    total_emissions_kg=round(total_emissions, 1),
                    segments=[seg_1, seg_2, seg_3],
                    debug_reason=f"Fly via {start_code}",
                )
            )
        return options
