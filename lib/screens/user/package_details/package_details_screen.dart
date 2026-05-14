import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelsphere/models/package_model.dart';
import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/widgets/common/custom_button.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';
import 'package:travelsphere/services/user_service.dart';
import 'package:travelsphere/services/booking_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:travelsphere/screens/user/package_details/map_view_screen.dart';

class PackageDetailsScreen extends StatelessWidget {
  final TravelPackage package;

  const PackageDetailsScreen({super.key, required this.package});

  String get _heroTag => 'package-hero-${package.id}';

  IconData _getIconForInclusion(String item) {
    switch (item.toLowerCase()) {
      case 'flights': return Icons.flight;
      case 'hotels': return Icons.hotel;
      case 'transfers': return Icons.directions_bus;
      case 'meals': return Icons.restaurant;
      case 'sightseeing': return Icons.camera_alt;
      case 'visa': return Icons.article;
      default: return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fallback
      body: Stack(
        children: [
          // 1. Fixed Background Image
          Positioned.fill(
            child: Hero(
              tag: _heroTag,
              child: CachedNetworkImage(
                imageUrl: package.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[900]),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
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
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.8),
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
                         color: Colors.white.withValues(alpha: 0.2),
                         shape: BoxShape.circle,
                       ),
                       child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    actions: [
                      StreamBuilder<DocumentSnapshot>(
                        stream: UserService().streamUserDoc(),
                        builder: (context, snapshot) {
                          bool isSaved = false;
                          if (snapshot.hasData && snapshot.data!.exists) {
                            final data = snapshot.data!.data() as Map<String, dynamic>?;
                            if (data != null) {
                              final savedIds = List<String>.from(data['saved_package_ids'] ?? []);
                              isSaved = savedIds.contains(package.id);
                            }
                          }
                          return Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                isSaved ? Icons.favorite : Icons.favorite_border,
                                color: isSaved ? Colors.redAccent : Colors.white,
                              ),
                              onPressed: () async {
                                try {
                                  await UserService().toggleSavedTrip(package.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(isSaved ? 'Removed from My Trips' : 'Saved to My Trips!')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: ${e.toString()}')),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        }
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
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: AppTheme.primaryBlue.withValues(alpha: 0.8),
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
                  color: Colors.black.withValues(alpha: 0.3), // Slight darken for content readability
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: GlassContainer(
                  useBlur: false,
                  borderRadius: 30, // Match visual
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  width: double.infinity,
                  child: TabBarView(
                    children: [
                      _buildOverviewTab(context),
                      _buildItineraryTab(context),
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
            onPressed: () => _showBookingSheet(context),
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
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.white.withValues(alpha: 0.05),
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
            style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 24),

          // What's Included (Dynamic)
          if (package.includedItems.isNotEmpty) ...[
            const Text(
              "What's Included",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            ...package.includedItems.map((item) => _buildInclusionTile(_getIconForInclusion(item), item)),
            const SizedBox(height: 24),
          ] else ...[
            // Fallback for older packages
            const Text(
              "What's Included",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            _buildInclusionTile(Icons.hotel, 'Comfortable Accommodation'),
            _buildInclusionTile(Icons.restaurant, 'Daily Breakfast & Dinner'),
            _buildInclusionTile(Icons.directions_bus, 'Local Transport'),
            _buildInclusionTile(Icons.camera_alt, 'Guided Sightseeing'),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildItineraryTab(BuildContext context) {
    if (package.itinerary.isEmpty) {
      return const Center(
        child: Text("Itinerary coming soon", style: TextStyle(color: Colors.white70)),
      );
    }

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
                       color: Colors.cyanAccent,
                     ),
                   ),
                   if (index != package.itinerary.length - 1)
                     Container(
                       width: 2,
                       height: 60,
                       color: Colors.white.withValues(alpha: 0.2),
                     ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showItineraryDayDetails(
                        context,
                        index + 1,
                        package.itinerary[index]['title'] ?? '',
                        package.itinerary[index]['description'] ?? '');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Day ${index + 1}',
                              style: const TextStyle(
                                color: Colors.cyanAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          package.itinerary[index]['title'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.w500, 
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          package.itinerary[index]['description'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, 
                              color: Colors.white70
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showItineraryDayDetails(BuildContext context, int day, String title, String details) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.today, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Day $day',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                details,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
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
                color: Colors.white.withValues(alpha: 0.1),
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

  void _showBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        int travelers = 1;
        DateTime? selectedDate;
        bool isBooking = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final totalPrice = package.price * travelers;

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: GlassContainer(
                borderRadius: 40,
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Book Your Trip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      package.name,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                    const Divider(height: 32, color: Colors.white24),

                    // Date Selection
                    const Text(
                      'Travel Date',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? now.add(const Duration(days: 7)),
                          firstDate: now.add(const Duration(days: 1)),
                          lastDate: now.add(const Duration(days: 365 * 2)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: AppTheme.primaryBlue,
                                  onPrimary: Colors.white,
                                  surface: Colors.grey[900]!,
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: AppTheme.primaryBlue, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              selectedDate == null
                                  ? 'Select Date'
                                  : DateFormat('EEE, MMM d, yyyy').format(selectedDate!),
                              style: TextStyle(
                                color: selectedDate == null ? Colors.white54 : Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Travelers Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Travelers',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.white),
                                onPressed: travelers > 1
                                    ? () => setModalState(() => travelers--)
                                    : null,
                              ),
                              Text(
                                '$travelers',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.white),
                                onPressed: travelers < 10
                                    ? () => setModalState(() => travelers++)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Summary and Checkout
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Price',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹$totalPrice',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 140,
                            child: CustomButton(
                              text: 'Confirm',
                              isLoading: isBooking,
                              onPressed: selectedDate == null
                                  ? null
                                  : () async {
                                      setModalState(() => isBooking = true);
                                      try {
                                        final user = FirebaseAuth.instance.currentUser;
                                        if (user == null) throw Exception('Please log in to book');

                                        await BookingService().createBooking(
                                          userId: user.uid,
                                          packageId: package.id,
                                          packageName: package.name,
                                          price: package.price,
                                          travelDate: selectedDate!,
                                          travelers: travelers,
                                        );

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Booking Confirmed! Check "My Trips"'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        setModalState(() => isBooking = false);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
