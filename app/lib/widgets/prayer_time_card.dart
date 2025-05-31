import 'package:app/core/constants.dart';
import 'package:flutter/material.dart';

class PrayerTimeCard extends StatelessWidget {
  final String title;
  final String time;
  final bool highlight;

  const PrayerTimeCard({
    super.key,
    required this.title,
    required this.time,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: highlight ? Colors.teal[100] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: highlight ? Border.all(color: accentColor, width: 1) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(1, 2),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(time, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
