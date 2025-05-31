import 'dart:async';
import 'package:flutter/material.dart';

class NextPrayerBanner extends StatefulWidget {
  final Map<String, String> prayerTimes;

  const NextPrayerBanner({super.key, required this.prayerTimes});

  @override
  State<NextPrayerBanner> createState() => _NextPrayerBannerState();
}

class _NextPrayerBannerState extends State<NextPrayerBanner> {
  String? nextPrayer;
  Duration? timeLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _calculateNextPrayer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _calculateNextPrayer();
    });
  }

  void _calculateNextPrayer() {
    final now = DateTime.now();
    DateTime? next;
    String? nextLabel;

    for (var entry in widget.prayerTimes.entries) {
      final label = entry.key;
      final timeStr = entry.value;

      final parts = timeStr.split(':');
      if (parts.length < 2) continue;

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      final prayerTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (prayerTime.isAfter(now)) {
        if (next == null || prayerTime.isBefore(next)) {
          next = prayerTime;
          nextLabel = label;
        }
      }
    }

    if (next == null) {
      // All today's prayers passed, fallback to tomorrow Fajr
      final fajrTime = widget.prayerTimes['Fajr']!;
      final parts = fajrTime.split(':');
      final fajrHour = int.tryParse(parts[0]) ?? 0;
      final fajrMinute = int.tryParse(parts[1]) ?? 0;
      next = DateTime(now.year, now.month, now.day + 1, fajrHour, fajrMinute);
      nextLabel = 'Fajr';
    }

    if (!mounted) return;
    setState(() {
      nextPrayer = nextLabel;
      timeLeft = next!.difference(now);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (nextPrayer == null || timeLeft == null) return const SizedBox();

    final hours = timeLeft!.inHours.toString().padLeft(2, '0');
    final minutes = (timeLeft!.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (timeLeft!.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Next: $nextPrayer in $hours:$minutes:$seconds',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
