class GeoPoint {
  final double lat;
  final double lng;
  final String? address;

  GeoPoint({required this.lat, required this.lng, this.address});

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String?,
    );
  }
}

class TripSegment {
  final String mode;
  final GeoPoint startPoint;
  final GeoPoint endPoint;
  final int durationMinutes;
  final double distanceMiles;
  final double costUsd;
  final String details;
  final String polyline;

  TripSegment({
    required this.mode,
    required this.startPoint,
    required this.endPoint,
    required this.durationMinutes,
    required this.distanceMiles,
    required this.costUsd,
    required this.details,
    required this.polyline,
  });

  factory TripSegment.fromJson(Map<String, dynamic> json) {
    return TripSegment(
      mode: json['mode'] as String,
      startPoint: GeoPoint.fromJson(json['start_point'] as Map<String, dynamic>),
      endPoint: GeoPoint.fromJson(json['end_point'] as Map<String, dynamic>),
      durationMinutes: json['duration_minutes'] as int,
      distanceMiles: (json['distance_miles'] as num).toDouble(),
      costUsd: (json['cost_usd'] as num).toDouble(),
      details: json['details'] as String,
      polyline: json['polyline'] as String? ?? '',
    );
  }
}

class TripOption {
  final String routeId;
  final double totalCost;
  final int totalDurationMinutes;
  final double totalEmissionsKg;
  final List<TripSegment> segments;
  final double rankingScore;
  final String debugReason;

  TripOption({
    required this.routeId,
    required this.totalCost,
    required this.totalDurationMinutes,
    required this.segments,
    this.totalEmissionsKg = 0.0,
    this.rankingScore = 0.0,
    this.debugReason = '',
  });

  factory TripOption.fromJson(Map<String, dynamic> json) {
    final segmentsList = json['segments'] as List<dynamic>? ?? [];
    return TripOption(
      routeId: json['route_id'] as String,
      totalCost: (json['total_cost'] as num).toDouble(),
      totalDurationMinutes: json['total_duration_minutes'] as int,
      segments: segmentsList
          .map((e) => TripSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalEmissionsKg:
          (json['total_emissions_kg'] as num?)?.toDouble() ?? 0.0,
      rankingScore: (json['ranking_score'] as num?)?.toDouble() ?? 0.0,
      debugReason: json['debug_reason'] as String? ?? '',
    );
  }

  String get durationFormatted {
    final h = totalDurationMinutes ~/ 60;
    final m = totalDurationMinutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  String get routeSummary {
    return segments.map((s) => s.mode == 'FLY' ? 'Flight' : 'Drive').join(' → ');
  }

  String get emissionsFormatted {
    if (totalEmissionsKg <= 0) return '—';
    return '${totalEmissionsKg.toStringAsFixed(0)} kg CO\u2082';
  }
}
