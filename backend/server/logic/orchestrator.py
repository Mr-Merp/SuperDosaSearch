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
        original_candidates = list(all_candidates)

        budget = request.user_profile.budget_usd
        if budget is not None:
            filtered = [opt for opt in all_candidates if opt.total_cost <= budget]
            if filtered:
                all_candidates = filtered
            else:
                cheapest = min(original_candidates, key=lambda o: o.total_cost, default=None)
                all_candidates = [cheapest] if cheapest is not None else []

        ranker = RankingEngine(request.user_profile)
        ranked_routes = ranker.rank(all_candidates)
        
        return ranked_routes