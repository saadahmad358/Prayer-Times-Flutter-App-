import 'package:flutter/material.dart';
import '../core/constants.dart';

class PrayerTimeCard extends StatelessWidget {
  final String title;
  final String time;

  const PrayerTimeCard({super.key, required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.access_time, color: Colors.teal[700]),
        title: Text(title, style: headingStyle),
        trailing: Text(time, style: timeStyle),
      ),
    );
  }
}
