import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/models/package_model.dart';
import 'package:travelsphere/screens/user/package_details/package_details_screen.dart';
import 'package:travelsphere/services/travel_package_service.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';

class PremiumDestinationScreen extends StatefulWidget {
  const PremiumDestinationScreen({super.key});

  @override
  State<PremiumDestinationScreen> createState() =>
      _PremiumDestinationScreenState();
}

class _PremiumDestinationScreenState extends State<PremiumDestinationScreen> {
  int _reloadToken = 0;
  int _currentPage = 0;
  late final PageController _pageController;
  late Stream<List<TravelPackage>> _packagesStream;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _packagesStream = TravelPackageService().getPackagesStream();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _reloadStream() {
    setState(() {
      _reloadToken++;
      _packagesStream = TravelPackageService().getPackagesStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: StreamBuilder<List<TravelPackage>>(
          key: ValueKey(_reloadToken),
          stream: _packagesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildStatusState(
                icon: Icons.travel_explore,
                title: 'Loading packages',
                message: 'Syncing packages from Firestore…',
                child: const CircularProgressIndicator(
                    color: AppTheme.primaryBlue),
              );
            }

            if (snapshot.hasError) {
              return _buildStatusState(
                icon: Icons.cloud_off,
                title: 'Unable to load packages',
                message: 'Check your network and try again.',
                actionLabel: 'Retry',
                onAction: _reloadStream,
              );
            }

            final packages = snapshot.data ?? [];
            if (packages.isEmpty) {
              return _buildStatusState(
                icon: Icons.search_off,
                title: 'No packages available',
                message:
                    "Add packages from the admin dashboard and they will appear here.",
                actionLabel: 'Back',
                onAction: () => Navigator.pop(context),
              );
            }

            return Stack(
              children: [
                // ── Reels-Style PageView ──
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: packages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final package = packages[index];
                    return _ReelPage(package: package);
                  },
                ),

                // ── Top overlay: back button + page indicator ──
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      GlassContainer(
                        borderRadius: 16,
                        padding: EdgeInsets.zero,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 22),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Spacer(),
                      GlassContainer(
                        borderRadius: 12,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Text(
                          '${_currentPage + 1} / ${packages.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Right-side scroll indicator dots ──
                if (packages.length > 1)
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _ScrollIndicator(
                        total: packages.length,
                        current: _currentPage,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
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
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassContainer(
            borderRadius: 24,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 54, color: Colors.white.withValues(alpha: 0.7)),
                const SizedBox(height: 16),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72))),
                if (child != null) ...[const SizedBox(height: 18), child],
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(actionLabel),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  Single "reel" page — full-screen image + glassmorphic info overlay
// ═══════════════════════════════════════════════════════════════════════════════

class _ReelPage extends StatelessWidget {
  final TravelPackage package;
  const _ReelPage({required this.package});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetails(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Full-screen image ──
          Hero(
            tag: 'package-hero-${package.id}',
            child: Image.network(
              package.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[900],
                child: const Center(
                    child: Icon(Icons.broken_image,
                        color: Colors.white24, size: 48)),
              ),
            ),
          ),

          // ── Gradient overlay (bottom heavy) ──
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.92),
                ],
                stops: const [0.0, 0.3, 0.65, 1.0],
              ),
            ),
          ),

          // ── Info overlay at bottom ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name + Rating
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
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
                              height: 1.2,
                              shadows: [
                                Shadow(
                                    color: Colors.black54,
                                    blurRadius: 8,
                                    offset: Offset(0, 2))
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                package.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.8)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            package.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Description (2 lines)
                    Text(
                      package.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Chips row: Duration + Price
                    Row(
                      children: [
                        _buildChip(Icons.schedule, package.duration),
                        const SizedBox(width: 10),
                        _buildChip(
                            Icons.currency_rupee, '₹${package.price}'),
                        if (package.includedItems.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          _buildChip(Icons.check_circle_outline,
                              '${package.includedItems.length} included'),
                        ],
                      ],
                    ),

                    const SizedBox(height: 16),

                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _openDetails(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('View Full Details',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Swipe hint (only shows briefly) ──
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.45,
            left: 0,
            right: 0,
            child: Center(
              child: Icon(
                Icons.keyboard_arrow_up_rounded,
                size: 32,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 5),
          Text(label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackageDetailsScreen(package: package),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  Scroll indicator (right-side dots like Instagram Reels)
// ═══════════════════════════════════════════════════════════════════════════════

class _ScrollIndicator extends StatelessWidget {
  final int total;
  final int current;
  const _ScrollIndicator({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    // Show max 7 dots at a time for long lists
    const maxVisible = 7;
    int start = 0;
    int end = total;

    if (total > maxVisible) {
      start = (current - maxVisible ~/ 2).clamp(0, total - maxVisible);
      end = start + maxVisible;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(end - start, (i) {
        final index = start + i;
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(vertical: 3),
          width: isActive ? 8 : 5,
          height: isActive ? 8 : 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
          ),
        );
      }),
    );
  }
}
