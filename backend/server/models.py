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
    state: Optional[str] = None

class UserProfile(BaseModel):
    user_id: str
    dollar_value_per_hour: float = 25.0 
    car_mpg: float = 25.0
    budget_usd: Optional[float] = None
    preference: Optional[str] = None
    learned_weights: Optional[dict[str, float]] = None

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
    
    total_cost: float
    total_duration_minutes: int 
    total_emissions_kg: float = 0.0
    
    segments: List[TripSegment]
    
    # score for ranking: higher is better
    ranking_score: float = 0.0
    debug_reason: str = ""

class RouteRequest(BaseModel):
    origin: GeoPoint
    destination: GeoPoint
    user_profile: UserProfile


class RouteSelectionFeedback(BaseModel):
    user_id: str
    route_id: str
