from dotenv import load_dotenv
load_dotenv("config.env")

import asyncio
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

@app.get("/health")
def health():
    return {"status": "ok"}

class SearchRequest(BaseModel):
    from_address: str
    to_address: str
    budget: float | None = None
    preference: str | None = None
    include_ridehail_airport_leg: bool = False

@app.post("/routes/search", response_model=List[TripOption])
async def search_routes(request: SearchRequest):
    origin, destination = await asyncio.gather(
        GoogleMapsService.geocode_address(request.from_address),
        GoogleMapsService.geocode_address(request.to_address),
    )

    route_request = RouteRequest(
        origin=origin,
        destination=destination,
        user_profile=UserProfile(
            user_id="default",
            budget_usd=request.budget,
            preference=request.preference,
            include_ridehail_airport_leg=request.include_ridehail_airport_leg,
        ),
    )

    orchestrator = RouteOrchestrator()
    results = await orchestrator.get_ranked_routes(route_request)
    return results[:10]
