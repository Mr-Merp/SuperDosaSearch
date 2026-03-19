from __future__ import annotations

from typing import Dict, List

from models import TripOption, TravelMode, UserProfile


class PersonalizationStore:
    _profiles: Dict[str, dict[str, float]] = {}
    _last_routes: Dict[str, List[TripOption]] = {}
    _metric_keys = ("cost", "time", "emissions", "transfers", "drive_miles")
    _default_weights = {
        "cost": 0.35,
        "time": 0.30,
        "emissions": 0.15,
        "transfers": 0.10,
        "drive_miles": 0.10,
    }

    @classmethod
    def attach_profile(cls, profile: UserProfile) -> UserProfile:
        weights = cls._profiles.get(profile.user_id)
        if weights:
            profile.learned_weights = dict(weights)
        return profile

    @classmethod
    def store_routes(cls, user_id: str, routes: List[TripOption]) -> None:
        cls._last_routes[user_id] = list(routes)

    @classmethod
    def record_selection(cls, user_id: str, route_id: str) -> bool:
        routes = cls._last_routes.get(user_id, [])
        selected = next((route for route in routes if route.route_id == route_id), None)
        if selected is None or not routes:
            return False

        profile = dict(cls._profiles.get(user_id, cls._default_weights))
        averages = cls._averages(routes)
        selected_metrics = cls._metrics(selected)
        learning_rate = 0.08

        for key in cls._metric_keys:
            average_value = averages[key]
            selected_value = selected_metrics[key]
            if selected_value < average_value:
                profile[key] += learning_rate
            elif selected_value > average_value:
                profile[key] = max(0.02, profile[key] - learning_rate / 2)

        total = sum(profile.values())
        if total > 0:
            profile = {key: value / total for key, value in profile.items()}

        cls._profiles[user_id] = profile
        return True

    @classmethod
    def _metrics(cls, route: TripOption) -> dict[str, float]:
        return {
            "cost": route.total_cost,
            "time": float(route.total_duration_minutes),
            "emissions": route.total_emissions_kg,
            "transfers": float(max(0, len(route.segments) - 1)),
            "drive_miles": sum(
                seg.distance_miles for seg in route.segments if seg.mode == TravelMode.DRIVE
            ),
        }

    @classmethod
    def _averages(cls, routes: List[TripOption]) -> dict[str, float]:
        sums = {key: 0.0 for key in cls._metric_keys}
        for route in routes:
            metrics = cls._metrics(route)
            for key in cls._metric_keys:
                sums[key] += metrics[key]
        count = float(len(routes))
        return {key: value / count for key, value in sums.items()}
