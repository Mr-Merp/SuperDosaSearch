from dotenv import load_dotenv
load_dotenv("config.env")

import asyncio
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
from models import RouteRequest, RouteSelectionFeedback, TripOption, UserProfile
from logic.orchestrator import RouteOrchestrator
from logic.maps import GoogleMapsService
from logic.personalization import PersonalizationStore

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
    user_id: str | None = None

@app.post("/routes/search", response_model=List[TripOption])
async def search_routes(request: SearchRequest):
    origin, destination = await asyncio.gather(
        GoogleMapsService.geocode_address(request.from_address),
        GoogleMapsService.geocode_address(request.to_address),
    )

    user_id = request.user_id or "default"
    route_request = RouteRequest(
        origin=origin,
        destination=destination,
        user_profile=PersonalizationStore.attach_profile(UserProfile(
            user_id=user_id,
            budget_usd=request.budget,
            preference=request.preference,
        )),
    )

    orchestrator = RouteOrchestrator()
    results = await orchestrator.get_ranked_routes(route_request)
    PersonalizationStore.store_routes(user_id, results)
    return results[:10]


@app.post("/routes/select")
async def select_route(feedback: RouteSelectionFeedback):
    accepted = PersonalizationStore.record_selection(
        feedback.user_id,
        feedback.route_id,
    )
    return {"ok": accepted}
