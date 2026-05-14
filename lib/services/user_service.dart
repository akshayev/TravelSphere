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

      final payload = <String, dynamic>{
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!docSnap.exists) {
        payload['role'] = 'user';
        payload['saved_package_ids'] = [];
        payload['createdAt'] = FieldValue.serverTimestamp();
      } else {
        final data = docSnap.data() as Map<String, dynamic>? ?? {};
        if (data['role'] == null) {
          payload['role'] = 'user';
        }
        if (data['saved_package_ids'] == null) {
          payload['saved_package_ids'] = [];
        }
      }

      await docRef.set(payload, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error ensuring user document: $e');
      }
      rethrow;
    }
  }

  /// Toggle saving a package for the current user
  Future<bool> toggleSavedTrip(String packageId) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');
    if (packageId.trim().isEmpty) throw Exception('Invalid package id');

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final docRef = _usersRef.doc(uid);
      await ensureUserDocument(user);

      return _firestore.runTransaction<bool>((transaction) async {
        final docSnap = await transaction.get(docRef);
        final data = docSnap.data() as Map<String, dynamic>? ?? {};
        final savedIds = List<String>.from(data['saved_package_ids'] ?? []);
        final isAlreadySaved = savedIds.contains(packageId);

        transaction.set(
          docRef,
          {
            'saved_package_ids': isAlreadySaved
                ? FieldValue.arrayRemove([packageId])
                : FieldValue.arrayUnion([packageId]),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        return !isAlreadySaved;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling saved trip: $e');
      }
      rethrow;
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
        updates['updatedAt'] = FieldValue.serverTimestamp();
        await _usersRef.doc(uid).set(updates, SetOptions(merge: true));
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
      await _usersRef.doc(user.uid).set({
        'displayName': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Reload to reflect changes across the app
      await user.reload();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating display name: $e');
      }
      rethrow;
    }
  }

  /// Update extra profile fields (bio, phoneNumber, birthYear) in Firestore
  Future<void> updateProfileFields({
    String? displayName,
    String? phoneNumber,
    String? bio,
    int? birthYear,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final updates = <String, dynamic>{};
    if (displayName != null && displayName.trim().isNotEmpty) {
      updates['displayName'] = displayName.trim();
    }
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber.trim();
    if (bio != null) updates['bio'] = bio.trim();
    if (birthYear != null) updates['birthYear'] = birthYear;

    if (updates.isEmpty) return;

    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _usersRef.doc(user.uid).set(updates, SetOptions(merge: true));

      // Keep Firebase Auth displayName in sync
      if (displayName != null && displayName.trim().isNotEmpty) {
        await user.updateProfile(displayName: displayName.trim());
        await user.reload();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile fields: $e');
      }
      rethrow;
    }
  }

  /// Persist notification preference toggles to Firestore
  Future<void> updateNotificationPrefs({
    bool? push,
    bool? email,
    bool? promo,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    final updates = <String, dynamic>{};
    if (push != null) updates['notifPush'] = push;
    if (email != null) updates['notifEmail'] = email;
    if (promo != null) updates['notifPromo'] = promo;

    if (updates.isEmpty) return;

    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _usersRef.doc(uid).set(updates, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error updating notification prefs: $e');
      }
      rethrow;
    }
  }
}

