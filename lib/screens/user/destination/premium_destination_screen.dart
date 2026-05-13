import 'package:flutter/material.dart';
import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/models/package_model.dart';
import 'package:travelsphere/screens/user/package_details/package_details_screen.dart';
import 'package:travelsphere/services/travel_package_service.dart';
import 'package:travelsphere/widgets/common/custom_button.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';

class PremiumDestinationScreen extends StatefulWidget {
  const PremiumDestinationScreen({super.key});

  @override
  State<PremiumDestinationScreen> createState() => _PremiumDestinationScreenState();
}

class _PremiumDestinationScreenState extends State<PremiumDestinationScreen> {
  int _reloadToken = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: StreamBuilder<List<TravelPackage>>(
          key: ValueKey(_reloadToken),
          stream: TravelPackageService().getPackagesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildStatusState(
                icon: Icons.travel_explore,
                title: 'Loading packages',
                message: 'Syncing the latest Firestore packages from your admin dashboard.',
                child: const CircularProgressIndicator(color: AppTheme.primaryBlue),
              );
            }

            if (snapshot.hasError) {
              return _buildStatusState(
                icon: Icons.cloud_off,
                title: 'Unable to load packages',
                message: 'Please check your network or Firestore rules, then try again.',
                actionLabel: 'Retry',
                onAction: () {
                  setState(() {
                    _reloadToken++;
                  });
                },
              );
            }

            final packages = snapshot.data ?? [];
            if (packages.isEmpty) {
              return _buildEmptyState();
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF10131A),
                          Color(0xFF06080C),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    _buildHeader(packages.length),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                        itemCount: packages.length,
                        itemBuilder: (context, index) {
                          final package = packages[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildPackagePage(context, package),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(int packageCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          GlassContainer(
            borderRadius: 18,
            padding: EdgeInsets.zero,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All Packages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Swipe up or down through $packageCount existing packages synced from Firestore',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagePage(BuildContext context, TravelPackage package) {
    final cardHeight = MediaQuery.of(context).size.height * 0.78;
    void openDetails() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PackageDetailsScreen(package: package),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: GestureDetector(
        onTap: openDetails,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: cardHeight.clamp(520.0, 760.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Stack(
              children: [
              Positioned.fill(
                child: Hero(
                  tag: _heroTag(package),
                  child: Image.network(
                    package.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.45),
                        Colors.black.withValues(alpha: 0.94),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 200),
                      GlassContainer(
                        borderRadius: 22,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    package.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GlassContainer(
                                  borderRadius: 14,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        package.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.white70),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    package.location,
                                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildInfoChip(Icons.schedule, package.duration),
                                _buildInfoChip(Icons.currency_rupee, '₹${package.price}'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              package.description,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                height: 1.45,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (package.includedItems.isNotEmpty) ...[
                              const Text(
                                'Included',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: package.includedItems.take(4).map((item) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                    ),
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (package.includedItems.length > 4) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '+${package.includedItems.length - 4} more included',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 18),
                            ],
                            if (package.itinerary.isNotEmpty) ...[
                              const Text(
                                'Itinerary preview',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...package.itinerary.take(1).map((day) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        day['title'] ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.cyanAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        day['description'] ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.82),
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ] else ...[
                              Text(
                                'Itinerary coming soon',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                              ),
                            ],
                            const SizedBox(height: 18),
                            CustomButton(
                              text: 'View Full Details',
                              onPressed: openDetails,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return _buildStatusState(
      icon: Icons.search_off,
      title: 'No packages available',
      message: 'Add packages in Firestore from the admin dashboard and they will appear here automatically.',
      actionLabel: 'Back',
      onAction: () => Navigator.pop(context),
    );
  }

  Widget _buildStatusState({
    required IconData icon,
    required String title,
    required String message,
    Widget? child,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 54, color: Colors.white.withValues(alpha: 0.7)),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
              ),
              if (child != null) ...[
                const SizedBox(height: 18),
                child,
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 18),
                CustomButton(text: actionLabel, onPressed: onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _heroTag(TravelPackage package) => 'package-hero-${package.id}';
}
