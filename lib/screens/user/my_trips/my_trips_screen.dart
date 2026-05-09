import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelsphere/models/package_model.dart';
import 'package:travelsphere/services/user_service.dart';
import 'package:travelsphere/services/booking_service.dart';
import 'package:travelsphere/services/travel_package_service.dart';
import 'package:travelsphere/widgets/common/package_card.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';
import 'package:travelsphere/app/theme.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = BookingService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userService.currentUserId;
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('My Trips', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyanAccent,
          indicatorWeight: 3,
          labelColor: Colors.cyanAccent,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Saved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Upcoming (booked, confirmed, travel date in the future)
          _buildBookingsTab(userId, isUpcoming: true),
          // Tab 2: Past (travel date has passed)
          _buildBookingsTab(userId, isUpcoming: false),
          // Tab 3: Saved/Wishlisted packages
          _buildSavedTab(),
        ],
      ),
    );
  }

  // ── Bookings Tab (Upcoming / Past) ──────────────────────────────────────────
  Widget _buildBookingsTab(String? userId, {required bool isUpcoming}) {
    if (userId == null) {
      return _buildEmptyState(
        icon: Icons.login,
        title: 'Not signed in',
        subtitle: 'Please log in to see your bookings.',
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _bookingService.getUserBookingsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
        }
        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.error_outline,
            title: 'Error loading bookings',
            subtitle: snapshot.error.toString(),
          );
        }

        final now = DateTime.now();
        final allDocs = snapshot.data?.docs ?? [];

        final filtered = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'confirmed';
          if (status == 'cancelled') return false;

          DateTime? travelDate;
          if (data['travelDate'] != null) {
            travelDate = DateTime.tryParse(data['travelDate']);
          }

          if (travelDate == null) return isUpcoming; // fallback

          return isUpcoming ? travelDate.isAfter(now) : travelDate.isBefore(now);
        }).toList();

        if (filtered.isEmpty) {
          return _buildEmptyState(
            icon: isUpcoming ? Icons.flight_takeoff : Icons.history,
            title: isUpcoming ? 'No upcoming trips' : 'No past trips',
            subtitle: isUpcoming
                ? 'Book a package to see it here!'
                : 'Your completed trips will appear here.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final doc = filtered[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildBookingCard(doc.id, data, isUpcoming: isUpcoming);
          },
        );
      },
    );
  }

  // ── Booking Card ────────────────────────────────────────────────────────────
  Widget _buildBookingCard(String bookingId, Map<String, dynamic> data, {required bool isUpcoming}) {
    final packageName = data['packageName'] ?? 'Unknown Package';
    final totalPrice = data['totalPrice'] ?? 0;
    final travelers = data['travelers'] ?? 1;
    final status = data['status'] ?? 'confirmed';

    DateTime? travelDate;
    if (data['travelDate'] != null) {
      travelDate = DateTime.tryParse(data['travelDate']);
    }

    final formattedDate = travelDate != null
        ? '${travelDate.day}/${travelDate.month}/${travelDate.year}'
        : 'N/A';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        useBlur: false,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUpcoming
                        ? Colors.cyanAccent.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isUpcoming ? Icons.flight_takeoff : Icons.check_circle_outline,
                    color: isUpcoming ? Colors.cyanAccent : Colors.greenAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        packageName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: status == 'confirmed'
                              ? Colors.greenAccent.withOpacity(0.15)
                              : Colors.orangeAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: status == 'confirmed' ? Colors.greenAccent : Colors.orangeAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Info chips
            Row(
              children: [
                _buildInfoChip(Icons.calendar_today, formattedDate),
                const SizedBox(width: 12),
                _buildInfoChip(Icons.people, '$travelers travelers'),
                const Spacer(),
                Text(
                  '₹$totalPrice',
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Cancel button for upcoming trips
            if (isUpcoming) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _confirmCancel(bookingId),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 18),
                  label: const Text('Cancel Trip', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white54),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  void _confirmCancel(String bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Cancel Booking?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to cancel this trip? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _bookingService.cancelBooking(bookingId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking cancelled.'), backgroundColor: Colors.orangeAccent),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            child: const Text('Cancel Trip', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // ── Saved Tab ───────────────────────────────────────────────────────────────
  Widget _buildSavedTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userService.streamUserDoc(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
        }

        List<String> savedPackageIds = [];
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final data = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
          savedPackageIds = List<String>.from(data['saved_package_ids'] ?? []);
        }

        if (savedPackageIds.isEmpty) {
          return _buildEmptyState(
            icon: Icons.bookmark_border,
            title: 'No saved trips',
            subtitle: 'Tap the heart icon on any package to save it here.',
          );
        }

        return StreamBuilder<List<TravelPackage>>(
          stream: TravelPackageService().getPackagesStream(),
          builder: (context, packagesSnapshot) {
            if (packagesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
            }
            if (packagesSnapshot.hasError || !packagesSnapshot.hasData) {
              return _buildEmptyState(
                icon: Icons.error_outline,
                title: 'Error loading packages',
                subtitle: '',
              );
            }

            final allPackages = packagesSnapshot.data!;
            final myPackages = allPackages.where((p) => savedPackageIds.contains(p.id)).toList();

            if (myPackages.isEmpty) {
              return _buildEmptyState(
                icon: Icons.bookmark_border,
                title: 'No saved trips',
                subtitle: 'Your saved packages may have been removed.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: myPackages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: PackageCard(package: myPackages[index]),
                );
              },
            );
          },
        );
      },
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.4))),
          ),
        ],
      ),
    );
  }
}
