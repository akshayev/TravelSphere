import 'package:flutter/material.dart';
import '../../../services/mock_data.dart';
import '../../../widgets/common/package_card.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../app/theme.dart';

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
      backgroundColor: Colors.grey[50], // Light background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Where do you\nwant to go?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryBlue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar
              CustomTextField(
                controller: _searchController,
                hint: 'Where to?',
                label: 'Search destinations...',
                prefixIcon: Icons.search,
                keyboardType: TextInputType.text, // Fixed parameter name
              ),
              const SizedBox(height: 24),

              // Categories
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        selectedColor: AppTheme.primaryBlue,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Popular Packages Header
              const Text(
                'Popular Trips',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 16),

              // Popular Packages List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: MockDataService.mockPackages.length,
                itemBuilder: (context, index) {
                  final package = MockDataService.mockPackages[index];
                  // Simple category filter (mock logic)
                  if (_selectedCategory != 'All' && !package.name.contains(_selectedCategory) && !package.location.contains(_selectedCategory)) {
                     // In a real app we would have tags/categories on the model.
                     // For now, this is just to show the list works.
                     // return const SizedBox.shrink(); 
                  }
                  
                  return PackageCard(
                    package: package,
                    onTap: () {
                      // Navigate to details (later)
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
