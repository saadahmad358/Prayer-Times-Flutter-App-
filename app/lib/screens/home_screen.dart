import 'package:app/core/constants.dart';
import 'package:app/widgets/shimmer_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prayer_timings.dart';
import '../services/prayer_api_service.dart';
import '../services/location_service.dart';
import '../services/city_suggestion_service.dart';
import '../widgets/prayer_time_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomeScreen({super.key, required this.toggleTheme});

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
      appBar: AppBar(
        title: const Text(
          'Prayer Times',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_timings != null) SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            today,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hijri: ${_timings!.hijriFormatted}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Next Prayer',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _timings!.nextPrayer,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Autocomplete<String>(
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

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryColor),
                        boxShadow: [
                          // BoxShadow(
                          //   color: Colors.black.withOpacity(0.05),
                          //   blurRadius: 8,
                          //   offset: const Offset(0, 4),
                          // ),
                        ],
                      ),
                      child: TextField(
                        cursorColor: primaryColor,
                        controller: controller,
                        focusNode: focusNode,
                        onSubmitted: (_) => _getPrayerTimes(),
                        style: const TextStyle(color: primaryColor),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.location_on_outlined,
                            color: primaryColor,
                          ),
                          hintText: 'Search city...',
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(127, 13, 148, 137),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search, color: primaryColor),
                            onPressed: _getPrayerTimes,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Divider(
                thickness: 1,
                color: const Color.fromARGB(40, 13, 148, 137),
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Column(
                  children: [
                    ShimmerCard(),
                    ShimmerCard(),
                    ShimmerCard(),
                    ShimmerCard(),
                    ShimmerCard(),
                  ],
                ),

              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_timings != null) ...[
                PrayerTimeCard(
                  title: 'Fajr',
                  time: _timings!.fajr,
                  highlight: _timings!.nextPrayer == 'Fajr',
                ),
                PrayerTimeCard(
                  title: 'Dhuhr',
                  time: _timings!.dhuhr,
                  highlight: _timings!.nextPrayer == 'Dhuhr',
                ),
                PrayerTimeCard(
                  title: 'Asr',
                  time: _timings!.asr,
                  highlight: _timings!.nextPrayer == 'Asr',
                ),
                PrayerTimeCard(
                  title: 'Maghrib',
                  time: _timings!.maghrib,
                  highlight: _timings!.nextPrayer == 'Maghrib',
                ),
                PrayerTimeCard(
                  title: 'Isha',
                  time: _timings!.isha,
                  highlight: _timings!.nextPrayer == 'Isha',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
