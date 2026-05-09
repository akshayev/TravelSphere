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
  final List<Map<String, String>> itinerary;
  final List<String> includedItems;
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
    required this.includedItems,
    this.locationCoordinates,
  });

  factory TravelPackage.fromJson(Map<String, dynamic> json, String id) {
    LatLng? coordinates;
    if (json['locationCoordinates'] != null) {
      final geoPoint = json['locationCoordinates'] as GeoPoint;
      coordinates = LatLng(geoPoint.latitude, geoPoint.longitude);
    }

    List<Map<String, String>> parsedItinerary = [];
    if (json['itinerary'] != null) {
      for (var e in (json['itinerary'] as List)) {
        if (e is String) {
          parsedItinerary.add({'title': 'Day', 'description': e});
        } else if (e is Map) {
          parsedItinerary.add({
            'title': e['title']?.toString() ?? '',
            'description': e['description']?.toString() ?? ''
          });
        }
      }
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
      itinerary: parsedItinerary,
      includedItems: List<String>.from(json['includedItems'] ?? []),
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
      'includedItems': includedItems,
      if (locationCoordinates != null)
        'locationCoordinates': GeoPoint(locationCoordinates!.latitude, locationCoordinates!.longitude),
    };
  }
}
