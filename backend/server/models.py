from pydantic import BaseModel
from typing import List, Optional
from enum import Enum

class TravelMode(str, Enum):
    # for now we just cover driving and flying ig
    DRIVE = "DRIVE"
    FLY = "FLY"

class GeoPoint(BaseModel):
    # we need lat and long for google maps api
    lat: float
    lng: float
    address: Optional[str] = None

class UserProfile(BaseModel):
    user_id: str
    # will prolly think of a better way to do tweak bias later not really sure how else to do it as of now
    bias_drive: float = 1.0       # >1.0 = prefers driving
    bias_fly: float = 1.0         # >1.0 = prefers flying
    dollar_value_per_hour: float = 25.0 
    max_tolerated_drive_min: int = 360  # 6 hours
    
    # basically a flag for less driving when it comes to airport + driving stuff
    minimize_driving_preference: bool = False 

class TripSegment(BaseModel):
    mode: TravelMode
    start_point: GeoPoint
    end_point: GeoPoint
    duration_minutes: int
    distance_miles: float
    cost_usd: float
    details: str 

class TripOption(BaseModel):
    route_id: str
    total_cost: float
    total_duration_minutes: int
    segments: List[TripSegment]
    ranking_score: float = 0.0
    debug_reason: str = ""

class RouteRequest(BaseModel):
    origin: GeoPoint
    destination: GeoPoint
    user_profile: UserProfile