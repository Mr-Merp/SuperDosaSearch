import asyncio
from typing import List
from models import RouteRequest, TripOption
from logic.strategies.driving import DrivingStrategy
from logic.strategies.flying import FlyingStrategy
from logic.ranking import RankingEngine

class RouteOrchestrator:
    def __init__(self):
        self.strategies = [
            DrivingStrategy(),
            FlyingStrategy()
        ]

    async def get_ranked_routes(self, request: RouteRequest) -> List[TripOption]:
        tasks = [strategy.generate_options(request) for strategy in self.strategies]
        results = await asyncio.gather(*tasks)
        
        all_candidates = [opt for sublist in results for opt in sublist]
        
        ranker = RankingEngine(request.user_profile)
        ranked_routes = ranker.rank(all_candidates)
        
        return ranked_routes