from fastapi import FastAPI
from typing import List
from models import RouteRequest, TripOption
from logic.orchestrator import RouteOrchestrator

app = FastAPI(title="Pathfinder Backend")

@app.post("/routes/search", response_model=List[TripOption])
async def search_routes(request: RouteRequest):
    orchestrator = RouteOrchestrator()
    results = await orchestrator.get_ranked_routes(request)
    
    # Return top 10 ranked results
    return results[:10]