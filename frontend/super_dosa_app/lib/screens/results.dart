import 'package:flutter/material.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String sortBy = 'recommended'; 

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

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
              Color(0xFF4A90E2), // Blue
              Color(0xFF7B68EE), // Purple
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, color: Color(0xFF4A90E2), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                data['from'] ?? 'Origin',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.arrow_forward, color: Colors.grey[400], size: 20),
                            const SizedBox(width: 16),
                            Icon(Icons.location_on, color: Color(0xFF7B68EE), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                data['to'] ?? 'Destination',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
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
                                  color: Color(0xFF4A90E2).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getPreferenceIcon(data['preference']!),
                                      size: 16,
                                      color: Color(0xFF4A90E2),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getPreferenceLabel(data['preference']!),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4A90E2),
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

              // Sort/Filter Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSortChip('Recommended', 'recommended', Icons.star),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSortChip('Price', 'price', Icons.attach_money),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSortChip('Time', 'time', Icons.access_time),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Results Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recommended Routes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Route Cards List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: const [
                    ModernRouteCard(
                      badge: 'Best Overall',
                      badgeColor: Colors.green,
                      title: 'Best Balance',
                      routeDetails: 'Train → Flight',
                      price: 180,
                      time: '4h 45m',
                      transfers: 1,
                      emissions: 'Low',
                      isRecommended: true,
                    ),
                    ModernRouteCard(
                      badge: 'Fastest',
                      badgeColor: Colors.orange,
                      title: 'Fastest Route',
                      routeDetails: 'Direct Flight',
                      price: 280,
                      time: '2h 10m',
                      transfers: 0,
                      emissions: 'Medium',
                      isRecommended: false,
                    ),
                    ModernRouteCard(
                      badge: 'Cheapest',
                      badgeColor: Colors.blue,
                      title: 'Cheapest Route',
                      routeDetails: 'Bus → Flight → Train',
                      price: 120,
                      time: '7h 30m',
                      transfers: 2,
                      emissions: 'Low',
                      isRecommended: false,
                    ),
                    ModernRouteCard(
                      badge: 'Eco-friendly',
                      badgeColor: Colors.green,
                      title: 'Eco-friendly Route',
                      routeDetails: 'Train → Bus',
                      price: 95,
                      time: '8h 15m',
                      transfers: 1,
                      emissions: 'Very Low',
                      isRecommended: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value, IconData icon) {
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
              color: isSelected ? Color(0xFF4A90E2) : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Color(0xFF4A90E2) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPreferenceIcon(String preference) {
    switch (preference) {
      case 'fastest':
        return Icons.speed;
      case 'cheapest':
        return Icons.attach_money;
      case 'eco':
        return Icons.eco;
      default:
        return Icons.balance;
    }
  }

  String _getPreferenceLabel(String preference) {
    switch (preference) {
      case 'fastest':
        return 'Fastest';
      case 'cheapest':
        return 'Cheapest';
      case 'eco':
        return 'Eco-friendly';
      default:
        return 'Balanced';
    }
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
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isRecommended
            ? BorderSide(color: badgeColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          // Navigate to route details or show bottom sheet
        },
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
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A90E2),
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
                      Color(0xFF4A90E2),
                      Color(0xFF7B68EE),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Show route details
                  },
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