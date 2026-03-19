from typing import List
from models import TripOption, UserProfile, TravelMode

class RankingEngine:
    def __init__(self, profile: UserProfile):
        self.profile = profile

    def _transfer_count(self, option: TripOption) -> int:
        return max(0, len(option.segments) - 1)

    def _drive_miles(self, option: TripOption) -> float:
        return sum(
            seg.distance_miles for seg in option.segments if seg.mode == TravelMode.DRIVE
        )

    def _normalize(self, value: float, minimum: float, maximum: float) -> float:
        if maximum <= minimum:
            return 0.0
        return (value - minimum) / (maximum - minimum)

    def _weights_for_preference(self, preference: str) -> dict[str, float]:
        weights = {
            "cost": 0.35,
            "time": 0.30,
            "emissions": 0.15,
            "transfers": 0.10,
            "drive_miles": 0.10,
        }

        if preference == "cheapest":
            return {
                "cost": 0.60,
                "time": 0.15,
                "emissions": 0.10,
                "transfers": 0.10,
                "drive_miles": 0.05,
            }
        if preference == "fastest":
            return {
                "cost": 0.15,
                "time": 0.60,
                "emissions": 0.10,
                "transfers": 0.10,
                "drive_miles": 0.05,
            }
        if preference == "eco":
            return {
                "cost": 0.15,
                "time": 0.15,
                "emissions": 0.55,
                "transfers": 0.05,
                "drive_miles": 0.10,
            }
        if preference == "fewest_transfers":
            return {
                "cost": 0.15,
                "time": 0.15,
                "emissions": 0.10,
                "transfers": 0.55,
                "drive_miles": 0.05,
            }
        if preference == "less_driving":
            return {
                "cost": 0.15,
                "time": 0.15,
                "emissions": 0.10,
                "transfers": 0.05,
                "drive_miles": 0.55,
            }
        return weights

    def calculate_score(
        self,
        option: TripOption,
        ranges: dict[str, tuple[float, float]],
        weights: dict[str, float],
    ) -> float:
        metrics = {
            "cost": option.total_cost,
            "time": float(option.total_duration_minutes),
            "emissions": option.total_emissions_kg,
            "transfers": float(self._transfer_count(option)),
            "drive_miles": self._drive_miles(option),
        }

        weighted_score = 0.0
        for key, value in metrics.items():
            minimum, maximum = ranges[key]
            weighted_score += self._normalize(value, minimum, maximum) * weights[key]

        return round(weighted_score, 4)

    def rank(self, options: List[TripOption]) -> List[TripOption]:
        if not options:
            return []

        preference = (self.profile.preference or "").lower()
        weights = self._weights_for_preference(preference)
        ranges = {
            "cost": (
                min(opt.total_cost for opt in options),
                max(opt.total_cost for opt in options),
            ),
            "time": (
                float(min(opt.total_duration_minutes for opt in options)),
                float(max(opt.total_duration_minutes for opt in options)),
            ),
            "emissions": (
                min(opt.total_emissions_kg for opt in options),
                max(opt.total_emissions_kg for opt in options),
            ),
            "transfers": (
                float(min(self._transfer_count(opt) for opt in options)),
                float(max(self._transfer_count(opt) for opt in options)),
            ),
            "drive_miles": (
                min(self._drive_miles(opt) for opt in options),
                max(self._drive_miles(opt) for opt in options),
            ),
        }

        for opt in options:
            opt.ranking_score = self.calculate_score(opt, ranges, weights)
            if preference == "cheapest":
                opt.debug_reason = "Cost-focused"
            elif preference == "fastest":
                opt.debug_reason = "Time-focused"
            elif preference == "eco":
                opt.debug_reason = "Emissions-focused"
            elif preference == "fewest_transfers":
                opt.debug_reason = "Fewest transfers"
            elif preference == "less_driving":
                opt.debug_reason = "Less driving"
            else:
                opt.debug_reason = "Balanced"

        return sorted(options, key=lambda x: x.ranking_score)
