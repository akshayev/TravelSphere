import 'package:latlong2/latlong.dart';

class TravelPackage {
  final String id;
  final String name;
  final String imageUrl;
  final int price;
  final double rating;
  final String duration;
  final String location;
  final String description;
  final List<String> itinerary;
  final LatLng? locationCoordinates;

  TravelPackage({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.duration,
    required this.location,
    required this.description,
    required this.itinerary,
    this.locationCoordinates,
  });
}
