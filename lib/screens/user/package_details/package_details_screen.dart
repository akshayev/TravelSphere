import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travelsphere/models/package_model.dart';
import '../../../app/theme.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/glass_container.dart';
import 'map_view_screen.dart';

class PackageDetailsScreen extends StatelessWidget {
  final TravelPackage package;

  const PackageDetailsScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fallback
      body: Stack(
        children: [
          // 1. Fixed Background Image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: package.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[900]),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),

          // 2. Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // 3. Content
          DefaultTabController(
            length: 2,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 300.0,
                    pinned: true,
                    backgroundColor: Colors.transparent, // Transparent to show bg
                    elevation: 0,
                    leading: Container(
                       margin: const EdgeInsets.all(8),
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.2),
                         shape: BoxShape.circle,
                       ),
                       child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.white),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to favorites!')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        // Transparent to show the fixed background stack
                      ),
                      title: Text(
                        package.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          shadows: [
                            Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black45),
                          ]
                        ),
                      ),
                      centerTitle: true,
                      titlePadding: const EdgeInsets.only(bottom: 60),
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(50),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: AppTheme.primaryBlue.withOpacity(0.8),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          tabs: const [
                            Tab(text: 'Overview'),
                            Tab(text: 'Itinerary'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: Container(
                margin: const EdgeInsets.only(top: 16), // Gap between tabs and content
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3), // Slight darken for content readability
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: GlassContainer(
                  borderRadius: 30, // Match visual
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  width: double.infinity,
                  child: TabBarView(
                    children: [
                      _buildOverviewTab(context),
                      _buildItineraryTab(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: GlassContainer(
        borderRadius: 0,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          top: false,
          child: CustomButton(
            text: 'Book Now - ₹${package.price}',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking Flow starts here! 🚀')),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatBadge(Icons.access_time, package.duration),
                _buildStatBadge(Icons.location_on, package.location),
                _buildStatBadge(Icons.star, '${package.rating} Rating'),
              ],
            ),
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
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          const Text(
            'About this trip',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            package.description,
            style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white.withOpacity(0.85)),
          ),
          const SizedBox(height: 24),

          // What's Included (Mock)
          const Text(
            "What's Included",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
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
      padding: const EdgeInsets.all(20),
      itemCount: package.itinerary.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                   Container(
                     width: 14,
                     height: 14,
                     decoration: const BoxDecoration(
                       shape: BoxShape.circle,
                       color: Colors.cyanAccent, // Bright accent for dark theme
                     ),
                   ),
                   if (index != package.itinerary.length - 1)
                     Container(
                       width: 2,
                       height: 60, // Approximate height connecting lines
                       color: Colors.white.withOpacity(0.2),
                     ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${index + 1}',
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        package.itinerary[index],
                        style: const TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.w500, 
                            color: Colors.white
                        ),
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
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.w500, 
              fontSize: 12, 
              color: Colors.white70
          ),
        ),
      ],
    );
  }

  Widget _buildInclusionTile(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 15, color: Colors.white)),
        ],
      ),
    );
  }
}
