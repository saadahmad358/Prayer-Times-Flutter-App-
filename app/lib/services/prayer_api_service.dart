import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_timings.dart';

class PrayerApiService {
  static const String _baseUrl = 'https://api.aladhan.com/v1/timingsByCity';

  static Future<PrayerTimings> fetchPrayerTimes(String city) async {
    final url = Uri.parse('$_baseUrl?city=$city&country=Pakistan&method=2');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return PrayerTimings.fromJson(data);
    } else {
      throw Exception('Failed to load prayer times');
    }
  }
}
