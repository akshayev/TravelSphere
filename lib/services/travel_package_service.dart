import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelsphere/models/package_model.dart';
import 'package:flutter/foundation.dart';

class TravelPackageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'packages';

  int _packageSortScore(TravelPackage package) {
    final timestamp = package.updatedAt ?? package.createdAt;
    return timestamp?.millisecondsSinceEpoch ?? 0;
  }

  Stream<List<TravelPackage>> getPackagesStream() {
    return _firestore.collection(_collectionPath).snapshots().map((snapshot) {
      final packages = snapshot.docs.map((doc) {
        return TravelPackage.fromJson(doc.data(), doc.id);
      }).toList();

      packages.sort((a, b) {
        final scoreDiff = _packageSortScore(b).compareTo(_packageSortScore(a));
        if (scoreDiff != 0) {
          return scoreDiff;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return packages;
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
      final payload = package.toJson();
      payload['createdAt'] = FieldValue.serverTimestamp();
      payload['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(_collectionPath).add(payload);
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
      final payload = package.toJson();
      payload['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(_collectionPath).doc(package.id).update(payload);
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
