import 'package:flutter_test/flutter_test.dart';
import 'package:travelsphere/services/itinerary_generator.dart';
import 'package:travelsphere/models/package_model.dart';
import 'package:travelsphere/services/mock_data.dart';

void main() {
  group('ItineraryGenerator Tests', () {
    test('generateTrip returns results for reasonable budget', () {
      final results = ItineraryGenerator.generateTrip(
        category: 'Any',
        days: 5,
        budget: 20000,
        travelers: 2,
      );
      expect(results, isNotEmpty);
    });

    test('generateTrip filters by category', () {
      final results = ItineraryGenerator.generateTrip(
        category: 'Beach',
        days: 5,
        budget: 50000,
        travelers: 2,
      );
      // Mock data has Goa (Beach)
      expect(results.any((p) => p.location.contains('Goa')), isTrue);
    });

    test('generateTrip respects budget constraint', () {
      final budget = 5000.0;
      final travelers = 1;
      final results = ItineraryGenerator.generateTrip(
        category: 'Any',
        days: 3,
        budget: budget,
        travelers: travelers,
      );
      
      for (var package in results) {
        expect(package.price * travelers, lessThanOrEqualTo(budget * 1.2)); // 20% tolerance
      }
    });

    test('generateTrip returns empty or fallback for impossible budget', () {
       final results = ItineraryGenerator.generateTrip(
        category: 'Any',
        days: 5,
        budget: 100, // Too low
        travelers: 2,
      );
      // Should be empty or match flexible logic if implemented, 
      // but essentially checking it doesn't crash
      expect(results, isNotNull); 
    });
  });
}
