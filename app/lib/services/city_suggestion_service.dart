import 'dart:convert';
import 'package:http/http.dart' as http;

class CitySuggestionService {
  static const String _apiKey =
      '1eaee6b298mshfc558e51d539af5p19539bjsnb0702b50e331';
  static const String _apiHost = 'wft-geo-db.p.rapidapi.com';

  static Future<List<String>> fetchCitySuggestions(String query) async {
    if (query.length < 2) return [];

    final url = Uri.https(_apiHost, '/v1/geo/cities', {
      'namePrefix': query,
      'countryIds': 'PK',
      'limit': '10',
      'sort': '-population',
    });

    final response = await http.get(
      url,
      headers: {'X-RapidAPI-Key': _apiKey, 'X-RapidAPI-Host': _apiHost},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['data'] as List)
          .map((city) => city['name'].toString())
          .toList();
    } else {
      print('API error: ${response.body}');
      return [];
    }
  }
}
