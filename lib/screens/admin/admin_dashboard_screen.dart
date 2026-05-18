import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/models/package_model.dart';
import 'package:travelsphere/services/travel_package_service.dart';
import 'package:travelsphere/services/booking_service.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';
import 'package:travelsphere/widgets/common/smart_network_image.dart';
import 'package:travelsphere/screens/admin/package_form_dialog.dart';
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _packageService = TravelPackageService();
  final _bookingService = BookingService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyanAccent,
          labelColor: Colors.cyanAccent,
          unselectedLabelColor: Colors.white54,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Packages'),
            Tab(text: 'Bookings'),
            Tab(text: 'Users'),
            Tab(text: 'Categories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPackagesTab(),
          _buildBookingsTab(),
          _buildUsersTab(),
          _buildCategoriesTab(),
        ],
      ),
    );
  }

// ── 1. Overview Tab ─────────────────────────────────────────────────────────
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System Overview', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Packages', Icons.map, FirebaseFirestore.instance.collection('packages').count().get().then((v) => v.count.toString()))),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Users', Icons.people, FirebaseFirestore.instance.collection('users').count().get().then((v) => v.count.toString()))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Bookings', Icons.book_online, FirebaseFirestore.instance.collection('bookings').count().get().then((v) => v.count.toString()))),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Categories', Icons.category, FirebaseFirestore.instance.collection('categories').count().get().then((v) => v.count.toString()))),
            ],
          ),
          const SizedBox(height: 16),
          _buildRevenueCard(),
        ],
      ),
    );
  }

  Widget _buildRevenueCard() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('bookings').where('status', isEqualTo: 'confirmed').get(),
      builder: (context, snapshot) {
        int totalRevenue = 0;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            totalRevenue += (data['totalPrice'] as num?)?.toInt() ?? 0;
          }
        }
        final revenueWidget = snapshot.connectionState == ConnectionState.waiting
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : Text('₹$totalRevenue', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold));
        return GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 16,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.attach_money, color: Colors.greenAccent, size: 32),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Revenue', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  revenueWidget,
                ],
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _buildStatCard(String title, IconData icon, Future<String?> futureValue) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      child: Column(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 32),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          FutureBuilder<String?>(
            future: futureValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2));
              }
              return Text(
                snapshot.data ?? '0',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              );
            },
          )
        ],
      ),
    );
  }

  // ── 2. Packages Tab ─────────────────────────────────────────────────────────
  Widget _buildPackagesTab() {
    return Stack(
      children: [
        StreamBuilder<List<TravelPackage>>(
          stream: _packageService.getPackagesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
            }
            final packages = snapshot.data ?? [];
            if (packages.isEmpty) {
              return const Center(child: Text('No packages found', style: TextStyle(color: Colors.white70)));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final package = packages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassContainer(
                    useBlur: false,
                    padding: const EdgeInsets.all(12),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 50,
                        height: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SmartNetworkImage(
                            imageUrl: package.imageUrl,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            errorWidget: Container(
                              color: Colors.white.withValues(alpha: 0.05),
                              child: const Icon(Icons.landscape, color: Colors.white24, size: 28),
                            ),
                          ),
                        ),
                      ),
                      title: Text(package.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('₹${package.price} • ${package.duration}', style: const TextStyle(color: Colors.white70)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue),
                            onPressed: () => _showPackageForm(package),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _deletePackage(package.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: AppTheme.primaryBlue,
            onPressed: () => _showPackageForm(null),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showPackageForm([TravelPackage? package]) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => PackageFormDialog(package: package),
    );
  }

  Future<void> _deletePackage(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Package', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirmed == true) {
      await _packageService.deletePackage(id);
    }
  }

  // ── 3. Bookings Tab ─────────────────────────────────────────────────────────
  Widget _buildBookingsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _bookingService.getAllBookingsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));

        final bookings = snapshot.data?.docs ?? [];
        if (bookings.isEmpty) return const Center(child: Text('No bookings yet', style: TextStyle(color: Colors.white70)));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final docId = bookings[index].id;
            final data = bookings[index].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';
            final pkgName = data['packageName'] ?? 'Unknown';
            final price = data['totalPrice'] ?? 0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                useBlur: false,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(pkgName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('₹$price', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('User: ${data['userId'].toString().substring(0, 8)}...', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: status == 'confirmed' ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(status.toUpperCase(), style: TextStyle(color: status == 'confirmed' ? Colors.greenAccent : Colors.redAccent, fontSize: 10)),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.white70, size: 20),
                              color: const Color(0xFF1E1E1E),
                              onSelected: (action) async {
                                if (action == 'confirm') {
                                  await FirebaseFirestore.instance.collection('bookings').doc(docId).update({'status': 'confirmed'});
                                } else if (action == 'cancel') {
                                  await _bookingService.cancelBooking(docId);
                                }
                              },
                              itemBuilder: (context) => [
                                if (status != 'confirmed')
                                  const PopupMenuItem(value: 'confirm', child: Text('Confirm Booking', style: TextStyle(color: Colors.greenAccent))),
                                if (status != 'cancelled')
                                  const PopupMenuItem(value: 'cancel', child: Text('Cancel Booking', style: TextStyle(color: Colors.redAccent))),
                              ],
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── 4. Users Tab ────────────────────────────────────────────────────────────
  Widget _buildUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        
        final users = snapshot.data?.docs ?? [];
        if (users.isEmpty) return const Center(child: Text('No users found', style: TextStyle(color: Colors.white70)));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final doc = users[index];
            final data = doc.data() as Map<String, dynamic>;
            final role = data['role'] ?? 'user';
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                useBlur: false,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: AppTheme.primaryBlue),
                  ),
                  title: Text(data['displayName'] ?? 'Unknown User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(data['email'] ?? 'No email', style: const TextStyle(color: Colors.white54)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (role == 'admin')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('ADMIN', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white70),
                        color: const Color(0xFF1E1E1E),
                        onSelected: (action) async {
                          try {
                            if (action == 'make_admin') {
                              await doc.reference.update({'role': 'admin'});
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('${data['displayName'] ?? 'User'} is now an Admin'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ));
                              }
                            } else if (action == 'revoke_admin') {
                              await doc.reference.update({'role': 'user'});
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('Admin access revoked for ${data['displayName'] ?? 'User'}'),
                                  backgroundColor: Colors.orangeAccent,
                                  behavior: SnackBarBehavior.floating,
                                ));
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Failed to update role: $e'),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ));
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          if (role != 'admin')
                            const PopupMenuItem(value: 'make_admin', child: Text('Make Admin', style: TextStyle(color: Colors.amber))),
                          if (role == 'admin')
                            const PopupMenuItem(value: 'revoke_admin', child: Text('Revoke Admin', style: TextStyle(color: Colors.orangeAccent))),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── 5. Categories Tab ───────────────────────────────────────────────────────
  Widget _buildCategoriesTab() {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('categories').orderBy('name').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) return const Center(child: Text('No categories added', style: TextStyle(color: Colors.white70)));

            return ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassContainer(
                    useBlur: false,
                    padding: const EdgeInsets.all(12),
                    child: ListTile(
                      title: Text(data['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () {
                          FirebaseFirestore.instance.collection('categories').doc(docs[index].id).delete();
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: AppTheme.primaryBlue,
            onPressed: () {
              final controller = TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: const Text('Add Category', style: TextStyle(color: Colors.white)),
                  content: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(hintText: 'Category Name', hintStyle: TextStyle(color: Colors.white54)),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          FirebaseFirestore.instance.collection('categories').add({'name': controller.text.trim()});
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add', style: TextStyle(color: Colors.cyanAccent)),
                    ),
                  ],
                ),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
