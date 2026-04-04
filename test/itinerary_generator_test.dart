// TODO: Rewrite tests for live Firestore data

// TODO: Rewrite tests for live Firestore data
/*
import 'package:travelsphere/models/package_model.dart';
import 'package:travelsphere/services/itinerary_generator.dart';

void main() {
  group('ItineraryGenerator Tests', () {
    final List<TravelPackage> mockPackages = [
      TravelPackage(
        id: '1',
        name: 'Goa Getaway',
        imageUrl: '',
        price: 5000,
        rating: 4.5,
        duration: '5 Days',
        location: 'Goa',
        description: 'Beach holiday',
        itinerary: [],
      ),
      TravelPackage(
        id: '2',
        name: 'Mountain Retreat',
        imageUrl: '',
        price: 15000,
        rating: 4.8,
        duration: '3 Days',
        location: 'Manali',
        description: 'Mountain scenes',
        itinerary: [],
      ),
    ];

    test('generateTrip returns results for reasonable budget', () async {
      final results = await ItineraryGenerator.generateTrip(
        category: 'Any',
        days: 5,
        budget: 20000,
        travelers: 2,
        availablePackages: mockPackages,
      );
      expect(results, isNotEmpty);
    });

    test('generateTrip filters by category', () async {
      final results = await ItineraryGenerator.generateTrip(
        category: 'Beach',
        days: 5,
        budget: 50000,
        travelers: 2,
        availablePackages: mockPackages,
      );
      expect(results.any((p) => p.location.contains('Goa') || p.description.contains('Beach')), isTrue);
    });

    test('generateTrip respects budget constraint', () async {
      const budget = 5000.0;
      const travelers = 1;
      final results = await ItineraryGenerator.generateTrip(
        category: 'Any',
        days: 3,
        budget: budget,
        travelers: travelers,
        availablePackages: mockPackages,
      );
      for (var package in results) {
        expect(package.price * travelers, lessThanOrEqualTo(budget * 1.2));
      }
    });

    test('generateTrip returns empty for impossible budget', () async {
      final results = await ItineraryGenerator.generateTrip(
        category: 'Any',
        days: 5,
        budget: 100,
        travelers: 2,
        availablePackages: mockPackages,
      );
      expect(results, isEmpty);
    });
  });
}
*/

void main() {
  // Tests commented out pending rewrite for live Firestore data.
  // See TODO above.
}

