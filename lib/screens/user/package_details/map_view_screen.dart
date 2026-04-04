import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/models/package_model.dart';
import 'package:travelsphere/services/travel_package_service.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';
import 'package:travelsphere/screens/user/package_details/package_details_screen.dart';

class MapViewScreen extends StatelessWidget {
  final String locationName;

  const MapViewScreen({super.key, required this.locationName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark themed background
      extendBodyBehindAppBar: true,  // For glassmorphism aesthetic
      appBar: AppBar(
        title: Text(locationName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<TravelPackage>>(
        stream: TravelPackageService().getPackagesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text('Error loading map data.', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
            );
          }

          final packages = snapshot.data!;
          final validPackages = packages.where((p) => p.locationCoordinates != null).toList();

          if (validPackages.isEmpty) {
            return Center(
              child: Text('No coordinates available on loaded map.', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
            );
          }

          // Calculate bounds to automatically center and zoom (Task 4)
          final points = validPackages.map((p) => p.locationCoordinates!).toList();
          final bounds = LatLngBounds.fromPoints(points);

          return FlutterMap(
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(60.0),
              ),
              // Fallback just in case bounds logic has issues on singular points
              initialCenter: points.first, 
            ),
            children: [
              TileLayer(
                // Use a dark map tile equivalent for better aesthetics
                urlTemplate: 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.travelsphere',
              ),
              MarkerLayer(
                markers: validPackages.map((package) {
                  return Marker(
                    point: package.locationCoordinates!,
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        _showPackageDetailsSheet(context, package);
                      },
                      child: const GlassContainer(
                        borderRadius: 25,
                        padding: EdgeInsets.zero,
                        child: Center(
                          child: Icon(
                            Icons.location_on,
                            color: AppTheme.primaryBlue,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPackageDetailsSheet(BuildContext context, TravelPackage package) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassContainer(
            borderRadius: 24,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white.withValues(alpha: 0.7), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      package.location,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PackageDetailsScreen(package: package),
                        ),
                      );
                    },
                    child: const Text('View Details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16), // Padding for the bottom safe area
              ],
            ),
          ),
        );
      },
    );
  }
}
