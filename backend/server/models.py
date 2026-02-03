"""
Data models for SuperDosaSearch
"""
from dataclasses import dataclass
from typing import List

@dataclass
class Route:
    title: str
    details: str
    price: int
    time: str
    
    def to_dict(self):
        return {
            'title': self.title,
            'details': self.details,
            'price': self.price,
            'time': self.time
        }

@dataclass
class SearchRequest:
    from_city: str
    to_city: str
    budget: float
