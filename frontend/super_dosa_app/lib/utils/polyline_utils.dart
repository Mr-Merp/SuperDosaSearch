import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:latlong2/latlong.dart';

List<LatLng> decodePolylineToLatLng(String encoded) {
  if (encoded.isEmpty) return [];
  final decoded = decodePolyline(encoded);
  return decoded
      .map((p) => LatLng(p[0].toDouble(), p[1].toDouble()))
      .toList();
}
