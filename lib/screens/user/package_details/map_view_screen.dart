import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../app/theme.dart';

class MapViewScreen extends StatelessWidget {
  final String locationName;
  // In a real app, we would pass LatLng coordinates here
  static const LatLng _dummyLocation = LatLng(15.2993, 74.1240); // Goa coordinates

  const MapViewScreen({super.key, required this.locationName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(locationName, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: _dummyLocation,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.travelsphere',
          ),
          const MarkerLayer(
            markers: [
              Marker(
                point: _dummyLocation,
                width: 80,
                height: 80,
                child: Icon(
                  Icons.location_on,
                  color: AppTheme.primaryBlue,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
