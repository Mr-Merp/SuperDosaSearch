"""
Flight API integration service
"""

class FlightAPI:
    def __init__(self, api_key=None):
        self.api_key = api_key
    
    def search_flights(self, from_city, to_city, date):
        """Search for available flights"""
        # TODO: Integrate with actual flight API (Skyscanner, Amadeus, etc.)
        pass
    
    def get_price(self, flight_id):
        """Get flight price"""
        pass
