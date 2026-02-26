"""
Convert airports.csv to a GeoJSON file suitable for MongoDB import.

Filters to only include airports where:
  - type is "large_airport" or "medium_airport", OR
  - scheduled_service is "yes"

Output: airports.geojson
  Each feature has a GeoJSON Point geometry and relevant properties.

To import into MongoDB:
  mongoimport --db <dbname> --collection airports --file airports.geojson --jsonArray

Then create the 2dsphere index in the mongo shell:
  db.airports.createIndex({ geometry: "2dsphere" })
"""

import csv
import json

INPUT_FILE = "airports.csv"
OUTPUT_FILE = "airports.geojson"

ALLOWED_TYPES = {"large_airport", "medium_airport"}

features = []

with open(INPUT_FILE, newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        airport_type = row.get("type", "")
        scheduled = row.get("scheduled_service", "no")

        if airport_type not in ALLOWED_TYPES and scheduled != "yes":
            continue

        try:
            lat = float(row["latitude_deg"])
            lng = float(row["longitude_deg"])
        except (ValueError, KeyError):
            continue

        feature = {
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": [lng, lat]  # GeoJSON order: [longitude, latitude]
            },
            "properties": {
                "iata_code": row.get("iata_code") or None,
                "icao_code": row.get("icao_code") or None,
                "name": row.get("name"),
                "type": airport_type,
                "scheduled_service": scheduled == "yes",
                "municipality": row.get("municipality"),
                "iso_country": row.get("iso_country"),
                "iso_region": row.get("iso_region"),
                "elevation_ft": int(row["elevation_ft"]) if row.get("elevation_ft") else None,
            }
        }
        features.append(feature)

geojson = {
    "type": "FeatureCollection",
    "features": features
}

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    json.dump(geojson, f)

print(f"Done. {len(features)} airports written to {OUTPUT_FILE}")
