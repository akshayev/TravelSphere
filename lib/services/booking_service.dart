import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final CollectionReference _bookingsCollection =
      FirebaseFirestore.instance.collection('bookings');

  Future<void> createBooking({
    required String userId,
    required String packageId,
    required String packageName,
    required int price,
    required DateTime travelDate,
    required int travelers,
  }) async {
    try {
      final payload = {
        'userId': userId,
        'packageId': packageId,
        'packageName': packageName,
        'totalPrice': price * travelers,
        'travelDate': travelDate.toIso8601String(),
        'travelers': travelers,
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _bookingsCollection.add(payload);
    } catch (e) {
      throw Exception('Failed to create booking: ${e.toString()}');
    }
  }
}
