import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Singleton pattern
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  String? get currentUserId => _auth.currentUser?.uid;
  User? get firebaseUser => _auth.currentUser;


  CollectionReference get _usersRef => _firestore.collection('users');

  /// Ensure the user document exists in Firestore. Run this after sign in/up.
  Future<void> ensureUserDocument(User user) async {
    try {
      final docRef = _usersRef.doc(user.uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        await docRef.set({
          'uid': user.uid,
          'email': user.email ?? '',
          'displayName': user.displayName ?? '',
          'photoURL': user.photoURL ?? '',
          'role': 'user',
          'saved_package_ids': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error ensuring user document: $e');
      }
    }
  }

  /// Toggle saving a package for the current user
  Future<void> toggleSavedTrip(String packageId) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');

    try {
      final docRef = _usersRef.doc(uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        // Fallback: create doc if it somehow doesn't exist
        await ensureUserDocument(_auth.currentUser!);
      }

      final data = docSnap.data() as Map<String, dynamic>? ?? {};
      final savedIds = List<String>.from(data['saved_package_ids'] ?? []);

      if (savedIds.contains(packageId)) {
        await docRef.update({
          'saved_package_ids': FieldValue.arrayRemove([packageId])
        });
      } else {
        await docRef.update({
          'saved_package_ids': FieldValue.arrayUnion([packageId])
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling saved trip: $e');
      }
    }
  }

  /// Stream current user's document for real-time updates (e.g. saved trips)
  Stream<DocumentSnapshot> streamUserDoc() {
    final uid = currentUserId;
    if (uid == null) {
      return const Stream.empty();
    }
    return _usersRef.doc(uid).snapshots();
  }

  /// Upload a given profile image file to Firebase Storage
  /// Returns the download URL if successful, or null on failure.
  Future<String?> uploadProfileImage(File imageFile) async {
    final uid = currentUserId;
    if (uid == null) return null;

    try {
      final ext = path.extension(imageFile.path);
      // Ensure specific extension format if needed, but simple append works.
      final ref = FirebaseStorage.instance.ref().child('profile_pics/$uid$ext');

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading profile image: $e');
      }
      return null;
    }
  }

  /// Update the Firestore user document with a new display name and photoURL
  Future<void> updateUserProfile({String? name, String? photoUrl}) async {
    final uid = currentUserId;
    if (uid == null) return;

    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['displayName'] = name;
      if (photoUrl != null) updates['photoURL'] = photoUrl;

      if (updates.isNotEmpty) {
        await _usersRef.doc(uid).update(updates);
      }
      
      // Update FirebaseAuth as well
      if (name != null || photoUrl != null) {
        await _auth.currentUser?.updateProfile(displayName: name, photoURL: photoUrl);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      rethrow;
    }
  }
  /// Update the display name in both Firebase Auth and Firestore
  Future<void> updateDisplayName(String newName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      // 1. Update Firebase Auth Profile
      await user.updateProfile(displayName: newName);

      // 2. Update Firestore Document
      await _usersRef.doc(user.uid).update({
        'displayName': newName,
      });

      // Reload to reflect changes across the app
      await user.reload();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating display name: $e');
      }
      rethrow;
    }
  }
}
