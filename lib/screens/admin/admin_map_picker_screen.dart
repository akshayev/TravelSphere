import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';

class AdminMapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const AdminMapPickerScreen({super.key, this.initialLocation});

  @override
  State<AdminMapPickerScreen> createState() => _AdminMapPickerScreenState();
}

class _AdminMapPickerScreenState extends State<AdminMapPickerScreen> {
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? const LatLng(20.5937, 78.9629); // Default to India
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final client = HttpClient();
      final request = await client.getUrl(
          Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1'));
      request.headers.add('User-Agent', 'com.travelsphere.app');
      
      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();
      final jsonResponse = jsonDecode(stringData) as List;

      if (jsonResponse.isNotEmpty) {
        final lat = double.parse(jsonResponse[0]['lat']);
        final lon = double.parse(jsonResponse[0]['lon']);
        setState(() {
          _selectedLocation = LatLng(lat, lon);
          _mapController.move(_selectedLocation!, 12.0);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location not found')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation!,
              initialZoom: widget.initialLocation != null ? 12.0 : 4.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.travelsphere.app',
                retinaMode: true,
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.redAccent, size: 40),
                    ),
                  ],
                ),
            ],
          ),
          
          // Search Bar & Back Button Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      margin: EdgeInsets.zero,
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                          suffixIcon: _isSearching
                              ? Container(
                                  padding: const EdgeInsets.all(12),
                                  width: 16,
                                  height: 16,
                                  child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.search, color: Colors.cyanAccent),
                                  onPressed: () => _searchLocation(_searchController.text),
                                ),
                        ),
                        onSubmitted: _searchLocation,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedLocation != null
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primaryBlue,
              onPressed: () => Navigator.pop(context, _selectedLocation),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('Save Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
