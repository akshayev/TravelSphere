import 'package:flutter/material.dart';
import 'package:travelsphere/models/package_model.dart';
import '../../app/theme.dart';
import 'dart:ui';
import 'package:travelsphere/widgets/common/glass_container.dart';

class PackageCard extends StatelessWidget {
  final TravelPackage package;
  final VoidCallback? onTap;

  const PackageCard({
    super.key,
    required this.package,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 250, // Fixed height for consistency
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. Full Background Image
              Positioned.fill(
                child: Image.network(
                  package.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[800],
                    child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white54)),
                  ),
                ),
              ),

              // 2. Gradient Overlay for readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.5, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Top Right Badge (Rating)
              Positioned(
                top: 16,
                right: 16,
                child: GlassContainer(
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        package.rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Bottom Content
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          package.location,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                         Text(
                          'From ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '₹${package.price}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.cyanAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
