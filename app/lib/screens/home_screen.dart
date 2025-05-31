import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prayer_timings.dart';
import '../services/prayer_api_service.dart';
import '../services/location_service.dart';
import '../services/city_suggestion_service.dart';
import '../widgets/next_prayer_banner.dart';
import '../widgets/prayer_time_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

  final TextEditingController _cityController = TextEditingController();
  PrayerTimings? _timings;
  bool _isLoading = false;
  String? _error;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _getCityAndFetchTimes();
  }

  Future<void> _getCityAndFetchTimes() async {
    final city = await LocationService.getCityName();
    if (city != null) {
      _cityController.text = city;
      _getPrayerTimes();
    }
  }

  Future<void> _getPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final timings = await PrayerApiService.fetchPrayerTimes(
        _cityController.text.trim(),
      );
      setState(() => _timings = timings);
    } catch (e) {
      setState(() => _error = 'Could not fetch prayer times.');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _fetchSuggestions(String query) async {
    final cities = await CitySuggestionService.fetchCitySuggestions(query);
    setState(() => _suggestions = cities);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Times'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                today,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text.length < 2) {
                    return const Iterable<String>.empty();
                  }
                  await _fetchSuggestions(textEditingValue.text);
                  return _suggestions;
                },
                onSelected: (String selectedCity) {
                  _cityController.text = selectedCity;
                  _getPrayerTimes();
                },
                fieldViewBuilder: (
                  context,
                  controller,
                  focusNode,
                  onFieldSubmitted,
                ) {
                  _cityController.text = controller.text;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Enter city',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _getPrayerTimes,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              if (_isLoading) const CircularProgressIndicator(),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_timings != null) ...[
                Text(
                  'Hijri Date: ${_timings!.hijriFormatted}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                NextPrayerBanner(
                  prayerTimes: {
                    'Fajr': _timings!.fajr,
                    'Dhuhr': _timings!.dhuhr,
                    'Asr': _timings!.asr,
                    'Maghrib': _timings!.maghrib,
                    'Isha': _timings!.isha,
                  },
                ),

                PrayerTimeCard(title: 'Fajr', time: _timings!.fajr),
                PrayerTimeCard(title: 'Dhuhr', time: _timings!.dhuhr),
                PrayerTimeCard(title: 'Asr', time: _timings!.asr),
                PrayerTimeCard(title: 'Maghrib', time: _timings!.maghrib),
                PrayerTimeCard(title: 'Isha', time: _timings!.isha),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
