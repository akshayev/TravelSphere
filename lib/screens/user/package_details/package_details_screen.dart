import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/package_model.dart';
import '../../../app/theme.dart';
import '../../../widgets/common/custom_button.dart';
import 'map_view_screen.dart';

class PackageDetailsScreen extends StatelessWidget {
  final TravelPackage package;

  const PackageDetailsScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                leading: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.white54,
                    child: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.white54,
                      child: Icon(Icons.favorite_border, color: Colors.black),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to favorites!')),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: package.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[300]),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                            stops: [0.6, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    package.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16 + 48), // Adjust for TabBar
                ),
                bottom: const TabBar(
                  indicatorColor: AppTheme.primaryBlue,
                  labelColor: Colors.black, // Depending on theme, might need adjustment if AppBar color changes on scroll
                  unselectedLabelColor: Colors.black54,
                  // Background color for TabBar to be visible when pinned
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(text: 'Overview'),
                    Tab(text: 'Itinerary'),
                  ],
                ),
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.black),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildOverviewTab(context),
              _buildItineraryTab(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: CustomButton(
          text: 'Book Now - ₹${package.price}',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking Flow starts here! 🚀')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatBadge(Icons.access_time, package.duration),
              _buildStatBadge(Icons.location_on, package.location),
              _buildStatBadge(Icons.star, '${package.rating} Rating'),
            ],
          ),
          const SizedBox(height: 24),

          // View on Map Button
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapViewScreen(locationName: package.location),
                  ),
                );
              },
              icon: const Icon(Icons.map, size: 18),
              label: const Text('View on Map'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
                side: const BorderSide(color: AppTheme.primaryBlue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          const Text(
            'About this trip',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            package.description,
            style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
          ),
          const SizedBox(height: 24),

          // What's Included (Mock)
          const Text(
            "What's Included",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildInclusionTile(Icons.hotel, 'Comfortable Accommodation'),
          _buildInclusionTile(Icons.restaurant, 'Daily Breakfast & Dinner'),
          _buildInclusionTile(Icons.directions_bus, 'Local Transport'),
          _buildInclusionTile(Icons.camera_alt, 'Guided Sightseeing'),
        ],
      ),
    );
  }

  Widget _buildItineraryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: package.itinerary.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                   Container(
                     width: 12,
                     height: 12,
                     decoration: const BoxDecoration(
                       shape: BoxShape.circle,
                       color: AppTheme.primaryBlue,
                     ),
                   ),
                   if (index != package.itinerary.length - 1)
                     Container(
                       width: 2,
                       height: 60, // Approximate height connecting lines
                       color: Colors.grey[300],
                     ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${index + 1}',
                        style: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        package.itinerary[index],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.darkGray),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInclusionTile(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryBlue.withAlpha(25), // Updated from withOpacity
            child: Icon(icon, size: 16, color: AppTheme.primaryBlue),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
