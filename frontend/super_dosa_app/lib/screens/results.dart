import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/route_models.dart';
import '../services/api_service.dart';
import '../services/api_config.dart';
import '../utils/polyline_utils.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String sortBy = 'recommended';
  final MapController _mapController = MapController();

  List<TripOption>? _routes;
  bool _loading = true;
  String? _error;
  int _selectedRouteIndex = 0;

  Color _primaryAccent(String preference) => preference == 'eco'
      ? const Color(0xFF2F9E44)
      : const Color(0xFF4A90E2);

  Color _secondaryAccent(String preference) => preference == 'eco'
      ? const Color(0xFF74B816)
      : const Color(0xFF7B68EE);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRoutes());
  }

  Future<void> _loadRoutes() async {
    final data = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    if (data == null) {
      setState(() {
        _loading = false;
        _error = 'Missing search parameters';
      });
      return;
    }
    final from = data['from'] ?? '';
    final to = data['to'] ?? '';
    final budgetStr = data['budget'];
    final preference = data['preference'];
    final budget = budgetStr != null && budgetStr.isNotEmpty
        ? (double.tryParse(budgetStr) ?? 0)
        : null;

    setState(() {
      _loading = true;
      _error = null;
      _routes = null;
    });

    try {
      final reachable = await ApiService.checkBackendReachable();
      if (!mounted) return;
      if (!reachable) {
        setState(() {
          _loading = false;
          _error =
              'Cannot reach backend at ${apiBaseUrl}. Start backend: cd backend/server && uvicorn main:app --reload --host 0.0.0.0 --port 5001';
        });
        return;
      }

      final routes = await ApiService.searchRoutes(
        from: from,
        to: to,
        budget: budget,
        preference: preference,
      );
      if (!mounted) return;
      setState(() {
        _routes = routes;
        _loading = false;
        _selectedRouteIndex = 0;
      });
      _fitMapToRoute();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _fitMapToRoute() {
    final route = _selectedRoute;
    if (route == null) return;
    final points = <LatLng>[];
    for (final seg in route.segments) {
      points.add(LatLng(seg.startPoint.lat, seg.startPoint.lng));
      points.add(LatLng(seg.endPoint.lat, seg.endPoint.lng));
      if (seg.polyline.isNotEmpty) {
        points.addAll(decodePolylineToLatLng(seg.polyline));
      }
    }
    if (points.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(points);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(24),
        ),
      );
    });
  }

  TripOption? get _selectedRoute {
    if (_routes == null || _routes!.isEmpty) return null;
    final i = _selectedRouteIndex.clamp(0, _routes!.length - 1);
    return _routes![i];
  }

  int get _cheapestIndex {
    if (_routes == null || _routes!.isEmpty) return 0;
    double best = _routes!.first.totalCost;
    int idx = 0;
    for (int i = 1; i < _routes!.length; i++) {
      if (_routes![i].totalCost < best) {
        best = _routes![i].totalCost;
        idx = i;
      }
    }
    return idx;
  }

  int get _fastestIndex {
    if (_routes == null || _routes!.isEmpty) return 0;
    int best = _routes!.first.totalDurationMinutes;
    int idx = 0;
    for (int i = 1; i < _routes!.length; i++) {
      if (_routes![i].totalDurationMinutes < best) {
        best = _routes![i].totalDurationMinutes;
        idx = i;
      }
    }
    return idx;
  }

  List<TripOption> get _sortedRoutes {
    if (_routes == null) return [];
    final routes = List<TripOption>.from(_routes!);
    if (sortBy == 'price') {
      routes.sort((a, b) => a.totalCost.compareTo(b.totalCost));
    } else if (sortBy == 'time') {
      routes.sort((a, b) => a.totalDurationMinutes.compareTo(b.totalDurationMinutes));
    }
    return routes;
  }

  Widget _buildRouteLocationField({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)?.settings.arguments as Map<String, String>? ?? {};
    final preference = data['preference'] ?? '';
    final primaryAccent = _primaryAccent(preference);
    final secondaryAccent = _secondaryAccent(preference);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryAccent,
              secondaryAccent,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Route Summary 
              Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Route Display
                        Row(
                          children: [
                            Expanded(
                              child: _buildRouteLocationField(
                                label: 'From',
                                value: data['from'] ?? 'Origin',
                                color: primaryAccent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: primaryAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: null,
                                icon: Icon(
                                  Icons.swap_horiz,
                                  color: primaryAccent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildRouteLocationField(
                                label: 'To',
                                value: data['to'] ?? 'Destination',
                                color: secondaryAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Budget and Preference
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.attach_money, color: Colors.green[600], size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  'Budget: \$${data['budget'] ?? '0'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            if (data['preference'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primaryAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getPreferenceIcon(data['preference']!),
                                      size: 16,
                                      color: primaryAccent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getPreferenceLabel(data['preference']!),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: primaryAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_loading)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Finding routes...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This can take 1–2 minutes for the first search.',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_error != null)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.white70),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                          TextButton.icon(
                            onPressed: _loadRoutes,
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            label: const Text('Retry', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_routes == null || _routes!.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No routes found.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                )
              else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                    child: _buildSortChip('Recommended', 'recommended', Icons.star, primaryAccent),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                    child: _buildSortChip('Price', 'price', Icons.attach_money, primaryAccent),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                    child: _buildSortChip('Time', 'time', Icons.access_time, primaryAccent),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Results Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: const Text(
                        'Recommended Routes',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left:3),
                        child: const Text(
                          'Your Journey',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )
                        )
                      )
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: _sortedRoutes.length,
                        itemBuilder: (context, index) {
                          final option = _sortedRoutes[index];
                          final originalIndex = _routes!.indexOf(option);
                          final isSelected = originalIndex == _selectedRouteIndex;
                          final bestIndex = 0;
                          final cheapestIndex = _cheapestIndex;
                          final fastestIndex = _fastestIndex;

                          String badge;
                          Color badgeColor;
                          if (originalIndex == bestIndex) {
                            badge = 'Best Overall';
                            badgeColor = Colors.green;
                          } else if (originalIndex == fastestIndex) {
                            badge = 'Fastest';
                            badgeColor = Colors.orange;
                          } else if (originalIndex == cheapestIndex) {
                            badge = 'Cheapest';
                            badgeColor = Colors.blue;
                          } else {
                            badge = 'Option ${originalIndex + 1}';
                            badgeColor = Colors.grey;
                          }

                          return ModernRouteCard(
                            badge: badge,
                            badgeColor: badgeColor,
                            title: option.routeSummary,
                            routeDetails: option.routeSummary,
                            price: option.totalCost.round(),
                            time: option.durationFormatted,
                            transfers: option.segments.length > 1 ? option.segments.length - 1 : 0,
                            emissions: option.emissionsFormatted,
                            isRecommended: originalIndex == bestIndex,
                            isSelected: isSelected,
                            ecoTheme: preference == 'eco',
                            onTap: () {
                              setState(() {
                                _selectedRouteIndex = originalIndex >= 0 ? originalIndex : index;
                              });
                              _fitMapToRoute();
                            },
                            onViewDetails: () => _showRouteDetails(option),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: _buildMapContent(),
                    ),
                  ],
                ),
              ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapContent() {
    final route = _selectedRoute;
    final data =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>? ?? {};
    final preference = data['preference'] ?? '';
    final primaryAccent = _primaryAccent(preference);
    final secondaryAccent = _secondaryAccent(preference);
    final initialCenter = route != null && route.segments.isNotEmpty
        ? LatLng(route.segments.first.startPoint.lat, route.segments.first.startPoint.lng)
        : const LatLng(37.7749, -122.4194);
    final markers = <Marker>[];
    final polylines = <Polyline>[];

    if (route != null && route.segments.isNotEmpty) {
      final first = route.segments.first;
      final last = route.segments.last;
      markers.add(
        Marker(
          point: LatLng(first.startPoint.lat, first.startPoint.lng),
          width: 40,
          height: 40,
          child: Icon(Icons.location_on, color: primaryAccent, size: 40),
        ),
      );
      markers.add(
        Marker(
          point: LatLng(last.endPoint.lat, last.endPoint.lng),
          width: 40,
          height: 40,
          child: Icon(Icons.location_on, color: secondaryAccent, size: 40),
        ),
      );
      for (final seg in route.segments) {
        if (seg.polyline.isNotEmpty) {
          final points = decodePolylineToLatLng(seg.polyline);
          if (points.isNotEmpty) {
            polylines.add(
              Polyline(
                points: points,
                strokeWidth: 5,
                color: primaryAccent,
              ),
            );
          }
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16, right: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey[300]!),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 8,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.super_dosa_search',
              ),
              if (polylines.isNotEmpty)
                PolylineLayer(polylines: polylines),
              MarkerLayer(markers: markers),
            ],
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Column(
              children: [
                                _buildZoomButton(Icons.add, () {
                                  _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
                                }, primaryAccent),
                                const SizedBox(height: 8),
                                _buildZoomButton(Icons.remove, () {
                                  _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
                                }, primaryAccent),
                              ],
                            ),
                          ),
        ],
      ),
    );
  }

  void _showRouteDetails(TripOption option) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Route Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        option.durationFormatted,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${option.totalCost.toStringAsFixed(0)} · ${option.segments.length - 1 > 0 ? '${option.segments.length - 1} transfers' : 'Direct'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: option.segments.length,
                      itemBuilder: (context, index) {
                        final seg = option.segments[index];
                        final isFlight = seg.mode == 'FLY';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isFlight ? Colors.blue.withOpacity(0.1) : Colors.purple.withOpacity(0.1),
                              child: Icon(
                                isFlight ? Icons.flight : Icons.directions_car,
                                color: isFlight ? Colors.blue : Colors.purple,
                              ),
                            ),
                            title: Text(seg.details),
                            subtitle: Text(
                              '${(seg.distanceMiles).toStringAsFixed(0)} miles · ${(seg.durationMinutes / 60).floor()}h ${seg.durationMinutes % 60}m',
                            ),
                            trailing: Text(
                              '\$${seg.costUsd.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip(String label, String value, IconData icon, Color accentColor) {
    final isSelected = sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          sortBy = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? accentColor : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? accentColor : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPreferenceIcon(String preference) {
    switch (preference) {
      case 'avoid_flights':
        return Icons.do_not_disturb_alt;
      case 'fastest':
        return Icons.speed;
      case 'cheapest':
        return Icons.attach_money;
      case 'eco':
        return Icons.eco;
      case 'fewest_transfers':
        return Icons.alt_route;
      case 'less_driving':
        return Icons.directions_car;
      default:
        return Icons.balance;
    }
  }

  String _getPreferenceLabel(String preference) {
    switch (preference) {
      case 'avoid_flights':
        return 'Avoid Flights';
      case 'fastest':
        return 'Fastest';
      case 'cheapest':
        return 'Cheapest';
      case 'eco':
        return 'Eco-friendly';
      case 'fewest_transfers':
        return 'Fewest Transfers';
      case 'less_driving':
        return 'Less Driving';
      default:
        return 'Balanced';
    }
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed, Color accentColor) {
      return SizedBox(
        height: 40,
        width: 40,
        child: FloatingActionButton(
          heroTag: null, 
          onPressed: onPressed,
          backgroundColor: Colors.white.withOpacity(0.9),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: accentColor, size: 20),
        ),
      );
    }
}

// Modern Route Card Widget
class ModernRouteCard extends StatelessWidget {
  final String badge;
  final Color badgeColor;
  final String title;
  final String routeDetails;
  final int price;
  final String time;
  final int transfers;
  final String emissions;
  final bool isRecommended;
  final bool isSelected;
  final bool ecoTheme;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;

  const ModernRouteCard({
    super.key,
    required this.badge,
    required this.badgeColor,
    required this.title,
    required this.routeDetails,
    required this.price,
    required this.time,
    required this.transfers,
    required this.emissions,
    required this.isRecommended,
    this.isSelected = false,
    this.ecoTheme = false,
    this.onTap,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: (isRecommended || isSelected)
            ? BorderSide(color: badgeColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge and Title Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getBadgeIcon(badge),
                          size: 14,
                          color: badgeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          badge,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: badgeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isRecommended) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'RECOMMENDED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              // Route Visualization
              Row(
                children: [
                  ..._buildRouteIcons(routeDetails),
                ],
              ),
              const SizedBox(height: 16),
              // Price and Time (Large)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$$price',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ecoTheme
                              ? const Color(0xFF2F9E44)
                              : const Color(0xFF4A90E2),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Duration',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 20, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Additional Info
              Row(
                children: [
                  _buildInfoChip(
                    Icons.swap_horiz,
                    '$transfers ${transfers == 1 ? 'transfer' : 'transfers'}',
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.eco,
                    emissions,
                    Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ecoTheme
                          ? const Color(0xFF2F9E44)
                          : const Color(0xFF4A90E2),
                      ecoTheme
                          ? const Color(0xFF74B816)
                          : const Color(0xFF7B68EE),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRouteIcons(String routeDetails) {
    final parts = routeDetails.split(' → ');
    List<Widget> widgets = [];
    
    for (int i = 0; i < parts.length; i++) {
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _getTransportColor(parts[i]).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getTransportIcon(parts[i]),
                size: 16,
                color: _getTransportColor(parts[i]),
              ),
              const SizedBox(width: 4),
              Text(
                parts[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getTransportColor(parts[i]),
                ),
              ),
            ],
          ),
        ),
      );
      
      if (i < parts.length - 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey[400]),
          ),
        );
      }
    }
    
    return widgets;
  }

  IconData _getTransportIcon(String transport) {
    if (transport.toLowerCase().contains('flight') || transport.toLowerCase().contains('plane')) {
      return Icons.flight;
    } else if (transport.toLowerCase().contains('train')) {
      return Icons.train;
    } else if (transport.toLowerCase().contains('bus')) {
      return Icons.directions_bus;
    } else if (transport.toLowerCase().contains('car') || transport.toLowerCase().contains('drive')) {
      return Icons.directions_car;
    }
    return Icons.directions;
  }

  Color _getTransportColor(String transport) {
    if (transport.toLowerCase().contains('flight') || transport.toLowerCase().contains('plane')) {
      return Colors.blue;
    } else if (transport.toLowerCase().contains('train')) {
      return Colors.orange;
    } else if (transport.toLowerCase().contains('bus')) {
      return Colors.green;
    } else if (transport.toLowerCase().contains('car') || transport.toLowerCase().contains('drive')) {
      return Colors.purple;
    }
    return Colors.grey;
  }

  IconData _getBadgeIcon(String badge) {
    if (badge.toLowerCase().contains('fastest')) {
      return Icons.speed;
    } else if (badge.toLowerCase().contains('cheapest')) {
      return Icons.attach_money;
    } else if (badge.toLowerCase().contains('eco')) {
      return Icons.eco;
    }
    return Icons.star;
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
