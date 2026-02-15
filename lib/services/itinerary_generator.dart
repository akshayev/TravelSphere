import '../models/package_model.dart';
import 'mock_data.dart';

class ItineraryGenerator {
  /// Generates a list of travel packages based on user preferences.
  /// 
  /// [category]: The selected destination category (e.g., "Beach", "Mountain", "Any").
  /// [days]: The desired duration of the trip in days.
  /// [budget]: The total budget for the trip.
  /// [travelers]: The number of travelers.
  static List<TravelPackage> generateTrip({
    required String category,
    required int days,
    required double budget,
    required int travelers,
  }) {
    final allPackages = MockDataService.mockPackages;
    
    // exact matches
    List<TravelPackage> matches = allPackages.where((package) {
      // 1. Calculate cost
      final totalCost = package.price * travelers;
      
      // 2. Parse duration (Assuming format "X Days")
      final packageDays = int.tryParse(package.duration.split(' ')[0]) ?? 0;
      
      // Filter Conditions
      final bool budgetCondition = totalCost <= budget;
      final bool durationCondition = (packageDays - days).abs() <= 1; // +/- 1 day tolerance
      final bool categoryCondition = category == 'Any' || 
                                     package.location.contains(category) || 
                                     package.name.contains(category) ||
                                     package.description.contains(category); // Simple keyword search

      return budgetCondition && durationCondition && categoryCondition;
    }).toList();

    // Advanced Logic: If no exact matches, relax budget constraint by 20%
    if (matches.isEmpty) {
      matches = allPackages.where((package) {
         final totalCost = package.price * travelers;
         final packageDays = int.tryParse(package.duration.split(' ')[0]) ?? 0;
         
         // Relaxed Budget (Budget + 20%)
         final bool budgetCondition = totalCost <= (budget * 1.2);
          // Relaxed Duration (+/- 2 days)
         final bool durationCondition = (packageDays - days).abs() <= 2;
         final bool categoryCondition = category == 'Any' || 
                                     package.location.contains(category) || 
                                     package.name.contains(category);

         return budgetCondition && durationCondition && categoryCondition;
      }).toList();
    }

    return matches;
  }
}
