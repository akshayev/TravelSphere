import 'package:travelsphere/models/package_model.dart';
import 'package:travelsphere/services/travel_package_service.dart';

class ItineraryGenerator {
  /// Generates a list of travel packages based on user preferences.
  ///
  /// [category]: Category name or slug (e.g., "Heritage & History", "Any").
  /// [days]: Desired trip duration in days.
  /// [budget]: Per-person budget.
  /// [travelers]: Number of travelers.
  static Future<List<TravelPackage>> generateTrip({
    required String category,
    required int days,
    required double budget,
    required int travelers,
    List<TravelPackage>? availablePackages,
  }) async {
    final allPackages =
        availablePackages ?? await TravelPackageService().getAllPackages();

    // Helper: parse "X Days Y Nights" or "X Days" → int
    int parseDays(String duration) {
      final match = RegExp(r'(\d+)\s*[Dd]ay').firstMatch(duration);
      return match != null ? int.parse(match.group(1)!) : 0;
    }

    // Helper: case-insensitive category check
    bool matchesCategory(TravelPackage pkg) {
      if (category == 'Any' || category.isEmpty) return true;
      final q = category.toLowerCase();
      return pkg.location.toLowerCase().contains(q) ||
          pkg.name.toLowerCase().contains(q) ||
          pkg.description.toLowerCase().contains(q);
    }

    // ── Pass 1: Exact match (per-person budget, +/- 1 day) ──
    List<TravelPackage> matches = allPackages.where((pkg) {
      final withinBudget = pkg.price <= budget;
      final packageDays = parseDays(pkg.duration);
      final withinDuration = (packageDays - days).abs() <= 1;
      return withinBudget && withinDuration && matchesCategory(pkg);
    }).toList();

    // ── Pass 2: Relax budget +25%, duration +/- 2 days ──
    if (matches.isEmpty) {
      matches = allPackages.where((pkg) {
        final withinBudget = pkg.price <= budget * 1.25;
        final packageDays = parseDays(pkg.duration);
        final withinDuration = (packageDays - days).abs() <= 2;
        return withinBudget && withinDuration && matchesCategory(pkg);
      }).toList();
    }

    // ── Pass 3: Category-only match, sorted by price ──
    if (matches.isEmpty) {
      matches = allPackages.where((pkg) {
        return pkg.price <= budget * 1.5 && matchesCategory(pkg);
      }).toList();
      matches.sort((a, b) => a.price.compareTo(b.price));
      if (matches.length > 5) matches = matches.sublist(0, 5);
    }

    // ── Pass 4: Top 5 cheapest overall as ultimate fallback ──
    if (matches.isEmpty) {
      matches = List.from(allPackages)
        ..sort((a, b) => a.price.compareTo(b.price));
      if (matches.length > 5) matches = matches.sublist(0, 5);
    }

    return matches;
  }
}
