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
    # rn set as some arbitrary default
    # this is how we will track user preferences for cost vs time tradeoffs
    dollar_value_per_hour: float = 25.0 
    
    # we will get this from an api key, set arbitrarily for now
    car_mpg: float = 25.0

class TripSegment(BaseModel):
    mode: TravelMode
    start_point: GeoPoint
    end_point: GeoPoint
    duration_minutes: int
    distance_miles: float
    cost_usd: float
    details: str 
    
    # pretty sure this we need this to display a map route with flutter
    polyline: str 

class TripOption(BaseModel):
    route_id: str
    
    # changed to a basic cost to duration cost exchange
    total_cost: float
    total_duration_minutes: int 
    
    segments: List[TripSegment]
    
    # score for ranking: higher is better
    ranking_score: float = 0.0
    debug_reason: str = ""

class RouteRequest(BaseModel):
    origin: GeoPoint
    destination: GeoPoint
    user_profile: UserProfile