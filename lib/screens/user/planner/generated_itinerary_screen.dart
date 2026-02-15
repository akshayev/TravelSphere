import 'package:flutter/material.dart';
import '../../../models/package_model.dart';
import '../../../widgets/common/package_card.dart';
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
      appBar: AppBar(
        title: const Text('Your Itinerary', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: results.isEmpty ? _buildEmptyState(context) : _buildResultsState(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No trips found for this budget.',
              style: TextStyle(fontSize: 18, color: AppTheme.darkGray, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try increasing your budget or changing the destination.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Adjust Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsState(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.green[600],
          child: Text(
            'We found ${results.length} trips for ₹${totalBudget.round()}!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final package = results[index];
              return PackageCard(
                package: package,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PackageDetailsScreen(package: package),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Colors.amber[50], // Light amber for tip
          child: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tip: Increasing budget by ₹2000 unlocks 3 more destinations.',
                  style: TextStyle(color: Colors.amber[900], fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
