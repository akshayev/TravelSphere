import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travelsphere/models/package_model.dart';
import '../../../widgets/common/package_card.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../app/theme.dart';
import '../package_details/package_details_screen.dart';

class GeneratedItineraryScreen extends StatelessWidget {
  final List<TravelPackage> results;
  final double totalBudget;

  const GeneratedItineraryScreen({
    super.key,
    required this.results,
    required this.totalBudget,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Your Itinerary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?q=80&w=2021&auto=format&fit=crop', // Same as planner
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.black),
              errorWidget: (context, url, error) => Container(color: Colors.black),
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
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          // 3. Content
          SafeArea(
            child: results.isEmpty ? _buildEmptyState(context) : _buildResultsState(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlassContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.white54),
              const SizedBox(height: 16),
              const Text(
                'No trips found for this budget.',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Try increasing your budget or changing the destination.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Adjust Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsState(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassContainer(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Text(
              'We found ${results.length} trips for ₹${totalBudget.round()}!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final package = results[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: PackageCard(
                  package: package,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PackageDetailsScreen(package: package),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        GlassContainer(
          width: double.infinity,
          borderRadius: 0,
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.amberAccent, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tip: Increasing budget by ₹2000 unlocks 3 more destinations.',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
