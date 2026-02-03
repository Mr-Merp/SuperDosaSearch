import 'package:flutter/material.dart';

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
