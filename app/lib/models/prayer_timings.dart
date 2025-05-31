class PrayerTimings {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String hijriFormatted;

  PrayerTimings({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriFormatted,
  });

  factory PrayerTimings.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'];
    final hijri = json['date']['hijri'];

    final day = hijri['day'] ?? '';
    final month = hijri['month']?['en'] ?? '';
    final year = hijri['year'] ?? '';
    final hijriFormatted = "$day $month $year";

    return PrayerTimings(
      fajr: timings['Fajr'] ?? '',
      dhuhr: timings['Dhuhr'] ?? '',
      asr: timings['Asr'] ?? '',
      maghrib: timings['Maghrib'] ?? '',
      isha: timings['Isha'] ?? '',
      hijriFormatted: hijriFormatted,
    );
  }
}
