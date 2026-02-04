import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final budgetController = TextEditingController();
  String selectedPreference = 'balanced';

  void _swapLocations() {
    final temp = fromController.text;
    fromController.text = toController.text;
    toController.text = temp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Findosa',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Find your perfect route',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const SizedBox(height: 40),

                  // Search Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // From Field
                          TextField(
                            controller: fromController,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'From',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.location_on,
                                color: Color(0xFF4A90E2),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFF4A90E2),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Swap Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF4A90E2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.swap_vert,
                                  color: Color(0xFF4A90E2),
                                ),
                                onPressed: _swapLocations,
                                tooltip: 'Swap locations',
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // To Field
                          TextField(
                            controller: toController,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'To',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.location_on,
                                color: Color(0xFF7B68EE),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFF7B68EE),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Budget Field
                          TextField(
                            controller: budgetController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Budget',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.attach_money,
                                color: Colors.green[600],
                              ),
                              prefixText: '\$ ',
                              prefixStyle: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.green[600]!,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Preference Chips
                          const Text(
                            'Preference',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildPreferenceChip('Fastest', 'fastest', Icons.speed),
                              _buildPreferenceChip('Cheapest', 'cheapest', Icons.attach_money),
                              _buildPreferenceChip('Balanced', 'balanced', Icons.balance),
                              _buildPreferenceChip('Eco-friendly', 'eco', Icons.eco),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Search Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF4A90E2),
                                  Color(0xFF7B68EE),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF4A90E2).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/results',
                                  arguments: {
                                    'from': fromController.text,
                                    'to': toController.text,
                                    'budget': budgetController.text,
                                    'preference': selectedPreference,
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search, color: Colors.white, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'Search Routes',
                                    style: TextStyle(
                                      fontSize: 18,
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

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceChip(String label, String value, IconData icon) {
    final isSelected = selectedPreference == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Color(0xFF4A90E2)),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedPreference = value;
        });
      },
      selectedColor: Color(0xFF4A90E2),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Color(0xFF4A90E2),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Color(0xFF4A90E2) : Colors.grey[300]!,
        width: isSelected ? 2 : 1,
      ),
    );
  }
}