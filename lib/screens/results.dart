import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final data =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              'From: ${data['from']}',
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              'To: ${data['to']}',
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              'Budget: \$${data['budget']}',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 25),

            const Text(
              'Recommended Routes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const RouteCard(
              title: 'Cheapest Route',
              details: 'Bus → Flight → Train',
              price: 120,
              time: '7h 30m',
            ),

            const RouteCard(
              title: 'Fastest Route',
              details: 'Direct Flight',
              price: 280,
              time: '2h 10m',
            ),

            const RouteCard(
              title: 'Best Balance',
              details: 'Train → Flight',
              price: 180,
              time: '4h 45m',
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------- Reusable Card ---------- */

class RouteCard extends StatelessWidget {
  final String title;
  final String details;
  final int price;
  final String time;

  const RouteCard({
    super.key,
    required this.title,
    required this.details,
    required this.price,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),

      child: ListTile(
        title: Text(title),
        subtitle: Text(details),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text('\$$price'),
            Text(time),
          ],
        ),
      ),
    );
  }
}