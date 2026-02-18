import 'package:flutter/material.dart';
import '../../../services/mock_data.dart';
import '../../../widgets/common/package_card.dart';
import '../package_details/package_details_screen.dart'; // Import Package Details

import '../../../app/theme.dart';

import 'dart:ui';
import 'package:travelsphere/widgets/common/glass_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['All', 'Beach', 'Mountain', 'Temple', 'City'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // 1. Glass Sliver App Bar
          SliverAppBar(
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?q=80&w=2070&auto=format&fit=crop', // Placeholder Hero Image
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80, // Space for search bar
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Your Next Adventure',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, const Color(0xFFF5F5F5)],
                    stops: const [0.0, 0.5], // Fade into body background
                  ),
                ),
                child: GlassContainer(
                  borderRadius: 16,
                  padding: EdgeInsets.zero,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search destinations...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Categories
          SliverToBoxAdapter(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          if (!isSelected)
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Popular Trips Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Trips',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/premium-destination');
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
          ),

          // 4. Packages List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final package = MockDataService.mockPackages[index];
                  // Simple category filter
                  if (_selectedCategory != 'All' &&
                      !package.name.contains(_selectedCategory) &&
                      !package.location.contains(_selectedCategory)) {
                    return const SizedBox.shrink();
                  }

                  return PackageCard(
                    package: package,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PackageDetailsScreen(package: package),
                        ),
                      );
                    },
                  );
                },
                childCount: MockDataService.mockPackages.length,
              ),
            ),
          ),
          
          // Bottom Padding
          SliverToBoxAdapter(child: const SizedBox(height: 80)),
        ],
      ),
    );
  }
}
