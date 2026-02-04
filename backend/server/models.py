# backend/models.py
from pydantic import BaseModel
from typing import List, Optional
from enum import Enum

class TravelMode(str, Enum):
    # for now we just cover driving and flying ig
    DRIVE = "DRIVE"
    FLY = "FLY"

class GeoPoint(BaseModel):
    lat: float
    lng: float
    address: Optional[str] = None

class UserProfile(BaseModel):
    user_id: str
    # This is the KEY variable for your "User History" ranking.
    # If they choose cheap/slow options -> this number goes DOWN.
    # If they choose fast/expensive options -> this number goes UP.
    dollar_value_per_hour: float = 25.0 
    
    # Simple car stats
    car_mpg: float = 25.0

class TripSegment(BaseModel):
    mode: TravelMode
    start_point: GeoPoint
    end_point: GeoPoint
    duration_minutes: int
    distance_miles: float
    cost_usd: float
    details: str 
    
    # CRITICAL FOR FLUTTER: The encoded string to draw the line on the map
    polyline: str 

class TripOption(BaseModel):
    route_id: str
    
    # These are the two competing factors for your ranking
    total_cost: float
    total_duration_minutes: int 
    
    segments: List[TripSegment]
    
    # The Calculated Score (Lower is better)
    ranking_score: float = 0.0
    debug_reason: str = ""

class RouteRequest(BaseModel):
    origin: GeoPoint
    destination: GeoPoint
    user_profile: UserProfile