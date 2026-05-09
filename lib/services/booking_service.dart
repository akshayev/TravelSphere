import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final CollectionReference _bookingsCollection =
      FirebaseFirestore.instance.collection('bookings');

  /// Create a new booking
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

  /// Stream all bookings for a specific user
  Stream<QuerySnapshot> getUserBookingsStream(String userId) {
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Cancel a booking by setting its status to 'cancelled'
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'status': 'cancelled',
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: ${e.toString()}');
    }
  }

  /// Stream all bookings (for admin)
  Stream<QuerySnapshot> getAllBookingsStream() {
    return _bookingsCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
