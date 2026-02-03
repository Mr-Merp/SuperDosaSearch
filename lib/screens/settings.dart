import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  double costVsSpeed = 0.5;
  bool avoidFlights = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              'Cost vs Speed',
              style: TextStyle(fontSize: 18),
            ),

            Slider(
              value: costVsSpeed,
              onChanged: (value) {
                setState(() {
                  costVsSpeed = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text('Avoid Flights'),
              value: avoidFlights,

              onChanged: (value) {
                setState(() {
                  avoidFlights = value;
                });
              },
            ),

          ],
        ),
      ),
    );
  }
}
