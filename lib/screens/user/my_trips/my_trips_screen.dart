import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelsphere/models/package_model.dart';
import 'package:travelsphere/services/user_service.dart';
import 'package:travelsphere/services/travel_package_service.dart';
import 'package:travelsphere/widgets/common/package_card.dart';
import 'package:travelsphere/app/theme.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme base
      appBar: AppBar(
        title: const Text('My Trips', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: UserService().streamUserDoc(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
          }
          if (userSnapshot.hasError) {
            return Center(child: Text('Error loading trips', style: TextStyle(color: Colors.white.withOpacity(0.7))));
          }
          
          List<String> savedPackageIds = [];
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            final data = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
            savedPackageIds = List<String>.from(data['saved_package_ids'] ?? []);
          }

          if (savedPackageIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 80, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text('You haven\'t saved any trips yet!', style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7))),
                  const SizedBox(height: 8),
                  Text('Start exploring', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5))),
                ],
              ),
            );
          }

          return StreamBuilder<List<TravelPackage>>(
            stream: TravelPackageService().getPackagesStream(),
            builder: (context, packagesSnapshot) {
              if (packagesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
              }
              if (packagesSnapshot.hasError || !packagesSnapshot.hasData) {
                return Center(child: Text('Error loading packages', style: TextStyle(color: Colors.white.withOpacity(0.7))));
              }

              final allPackages = packagesSnapshot.data!;
              
              // Filter out the packages that are in the user's saved array
              final myPackages = allPackages.where((p) => savedPackageIds.contains(p.id)).toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: myPackages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: PackageCard(package: myPackages[index]),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
