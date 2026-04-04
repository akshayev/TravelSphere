import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelsphere/models/package_model.dart';
import 'package:flutter/foundation.dart';

class TravelPackageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'packages';

  Stream<List<TravelPackage>> getPackagesStream() {
    return _firestore.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TravelPackage.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<List<TravelPackage>> getAllPackages() async {
    try {
      final snapshot = await _firestore.collection(_collectionPath).get();
      return snapshot.docs.map((doc) => TravelPackage.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching packages: $e');
      }
      rethrow;
    }
  }
  
  Future<TravelPackage?> getPackageById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return TravelPackage.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching package by id: $e');
      }
      return null;
    }
  }

  /// Add a new travel package to Firestore
  Future<void> addPackage(TravelPackage package) async {
    try {
      await _firestore.collection(_collectionPath).add(package.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Error adding package: $e');
      }
      rethrow;
    }
  }

  /// Update an existing travel package in Firestore
  Future<void> updatePackage(TravelPackage package) async {
    try {
      await _firestore.collection(_collectionPath).doc(package.id).update(package.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Error updating package: $e');
      }
      rethrow;
    }
  }

  /// Delete a travel package from Firestore
  Future<void> deletePackage(String packageId) async {
    try {
      await _firestore.collection(_collectionPath).doc(packageId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting package: $e');
      }
      rethrow;
    }
  }
}
