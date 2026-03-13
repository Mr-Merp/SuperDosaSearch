from typing import List
from models import TripOption, UserProfile

class RankingEngine:
    def __init__(self, profile: UserProfile):
        self.profile = profile

    def calculate_score(self, option: TripOption) -> float:
        financial_cost = option.total_cost
        hours = option.total_duration_minutes / 60.0
        time_cost = hours * self.profile.dollar_value_per_hour
        final_score = financial_cost + time_cost
        return round(final_score, 2)

    def rank(self, options: List[TripOption]) -> List[TripOption]:
        preference = (self.profile.preference or "").lower()

        if preference == "cheapest":
            for opt in options:
                opt.ranking_score = opt.total_cost
                opt.debug_reason = "Cheapest"
            return sorted(options, key=lambda x: x.total_cost)

        if preference == "fastest":
            for opt in options:
                opt.ranking_score = float(opt.total_duration_minutes)
                opt.debug_reason = "Fastest"
            return sorted(options, key=lambda x: x.total_duration_minutes)

        if preference == "eco":
            for opt in options:
                opt.ranking_score = opt.total_emissions_kg
                opt.debug_reason = "Eco-friendly"
            return sorted(options, key=lambda x: x.total_emissions_kg)

        for opt in options:
            opt.ranking_score = self.calculate_score(opt)
            hours = opt.total_duration_minutes / 60
            if opt.ranking_score < 200: 
                opt.debug_reason = "Best Value"
            elif hours > 12: # prolly subject to change based off of how far the stuff is
                opt.debug_reason = "Cheap, but extremely long"
            elif opt.total_cost > 600: # prolly subject to change based off of how far the stuff is
                opt.debug_reason = "Fast, but expensive"
                
        return sorted(options, key=lambda x: x.ranking_score)