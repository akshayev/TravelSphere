import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory TravelPackage.fromJson(Map<String, dynamic> json, String id) {
    LatLng? coordinates;
    if (json['locationCoordinates'] != null) {
      final geoPoint = json['locationCoordinates'] as GeoPoint;
      coordinates = LatLng(geoPoint.latitude, geoPoint.longitude);
    }

    return TravelPackage(
      id: id,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      price: json['price'] as int,
      rating: (json['rating'] as num).toDouble(),
      duration: json['duration'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      itinerary: List<String>.from(json['itinerary'] ?? []),
      locationCoordinates: coordinates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'rating': rating,
      'duration': duration,
      'location': location,
      'description': description,
      'itinerary': itinerary,
      if (locationCoordinates != null)
        'locationCoordinates': GeoPoint(locationCoordinates!.latitude, locationCoordinates!.longitude),
    };
  }
}
