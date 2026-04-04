import 'package:flutter/material.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';
import 'package:travelsphere/widgets/common/custom_button.dart';

class PremiumDestinationScreen extends StatelessWidget {
  const PremiumDestinationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Full Background Image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1573843981267-be1999ff37cd?q=80&w=1974&auto=format&fit=crop', // Maldives/Premium Image
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.black,
              ),
            ),
          ),

          // 2. Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 3. Back Button
          Positioned(
            top: 50,
            left: 20,
            child: GlassContainer(
              borderRadius: 50,
              padding: const EdgeInsets.all(8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 4. Content (Bottom Sheet Style)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Maldives Paradise',
                          style: TextStyle(
                            fontSize: 28, // Using explicit size instead of Theme for better control in Glass
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              '4.9',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Location
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white70, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Indian Ocean',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Experience the ultimate luxury in overwater villas with crystal clear waters and pristine white sandy beaches.',
                    style: TextStyle(color: Colors.white, height: 1.5, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // Features (Icons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureIcon(Icons.hotel, 'Resort'),
                      _buildFeatureIcon(Icons.restaurant, 'Dining'),
                      _buildFeatureIcon(Icons.pool, 'Pool'),
                      _buildFeatureIcon(Icons.wifi, 'Wifi'),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Price & Button
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            '₹45,000',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyanAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: CustomButton(
                          text: 'Book Now',
                          onPressed: () {
                              // Action to book
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
