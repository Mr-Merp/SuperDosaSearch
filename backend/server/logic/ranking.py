from typing import List
from models import TripOption, UserProfile

class RankingEngine:
    def __init__(self, profile: UserProfile):
        self.profile = profile

    def calculate_score(self, option: TripOption) -> float:
        """
        Calculates the 'Total Economic Cost' of the trip.
        Score = Cash Cost + (Time * User's Hourly Value)
        
        Example: 
        Option A: $100 ticket, 10 hours travel. User Value $10/hr.
        Score = 100 + (10 * 10) = 200.
        """
        
        financial_cost = option.total_cost
        
        hours = option.total_duration_minutes / 60.0
        time_cost = hours * self.profile.dollar_value_per_hour
        
        final_score = financial_cost + time_cost
        return round(final_score, 2)

    def rank(self, options: List[TripOption]) -> List[TripOption]:
        for opt in options:
            opt.ranking_score = self.calculate_score(opt)
            
            # idk im tired adding random debug stuff
            hours = opt.total_duration_minutes / 60
            if opt.ranking_score < 200: 
                opt.debug_reason = "Best Value"
            elif hours > 12: # prolly subject to change based off of how far the stuff is
                opt.debug_reason = "Cheap, but extremely long"
            elif opt.total_cost > 600: # prolly subject to change based off of how far the stuff is
                opt.debug_reason = "Fast, but expensive"
                
        return sorted(options, key=lambda x: x.ranking_score)