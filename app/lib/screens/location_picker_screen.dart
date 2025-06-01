import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;

  void _onTap(LatLng pos) {
    setState(() {
      _pickedLocation = pos;
    });
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Location')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(24.8607, 67.0011), // Default to Karachi
          zoom: 12,
        ),
        onMapCreated: (controller) => _mapController = controller,
        onTap: _onTap,
        markers:
            _pickedLocation != null
                ? {
                  Marker(
                    markerId: const MarkerId('picked'),
                    position: _pickedLocation!,
                  ),
                }
                : {},
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_pickedLocation != null) {
            Navigator.pop(context, _pickedLocation);
          }
        },
        label: const Text('Confirm'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
