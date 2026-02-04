from abc import ABC, abstractmethod
from typing import List
from models import RouteRequest, TripOption

class TravelStrategy(ABC):
    @abstractmethod
    async def generate_options(self, request: RouteRequest) -> List[TripOption]:
        """
        Returns a list of viable trip options for this specific mode.
        """
        pass