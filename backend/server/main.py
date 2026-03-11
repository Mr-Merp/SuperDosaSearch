from dotenv import load_dotenv
load_dotenv("config.env")

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
from models import RouteRequest, TripOption, UserProfile
from logic.orchestrator import RouteOrchestrator
from logic.maps import GoogleMapsService

app = FastAPI(title="Pathfinder Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class SearchRequest(BaseModel):
    from_address: str
    to_address: str

@app.post("/routes/search", response_model=List[TripOption])
async def search_routes(request: SearchRequest):
    print(f"/routes/search from={request.from_address} to={request.to_address}")
    origin = GoogleMapsService.geocode_address(request.from_address)
    destination = GoogleMapsService.geocode_address(request.to_address)

    route_request = RouteRequest(
        origin=origin,
        destination=destination,
        user_profile=UserProfile(user_id="default"),
    )

    orchestrator = RouteOrchestrator()
    results = await orchestrator.get_ranked_routes(route_request)
    return results[:10]
