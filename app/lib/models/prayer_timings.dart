class PrayerTimings {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String hijriFormatted;
  final String nextPrayer;

  PrayerTimings({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriFormatted,
    required this.nextPrayer,
  });

  factory PrayerTimings.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'];
    final hijri = json['date']['hijri'];

    final day = hijri['day'] ?? '';
    final month = hijri['month']?['en'] ?? '';
    final year = hijri['year'] ?? '';
    final hijriFormatted = "$day $month $year";

    final now = DateTime.now();
    final timeMap = {
      'Fajr': _parseTime(timings['Fajr'], now),
      'Dhuhr': _parseTime(timings['Dhuhr'], now),
      'Asr': _parseTime(timings['Asr'], now),
      'Maghrib': _parseTime(timings['Maghrib'], now),
      'Isha': _parseTime(timings['Isha'], now),
    };

    String next = 'Fajr'; // Default
    for (final entry in timeMap.entries) {
      if (entry.value.isAfter(now)) {
        next = entry.key;
        break;
      }
    }

    return PrayerTimings(
      fajr: timings['Fajr'] ?? '',
      dhuhr: timings['Dhuhr'] ?? '',
      asr: timings['Asr'] ?? '',
      maghrib: timings['Maghrib'] ?? '',
      isha: timings['Isha'] ?? '',
      hijriFormatted: hijriFormatted,
      nextPrayer: next,
    );
  }

  static DateTime _parseTime(String? timeStr, DateTime now) {
    if (timeStr == null || !timeStr.contains(':'))
      return now.add(const Duration(days: 1));
    final parts = timeStr.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}
