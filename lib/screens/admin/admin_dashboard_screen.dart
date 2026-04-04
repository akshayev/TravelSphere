import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/models/package_model.dart';
import 'package:travelsphere/services/travel_package_service.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';
import 'package:travelsphere/screens/admin/package_form_dialog.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _packageService = TravelPackageService();

  void _showPackageForm([TravelPackage? package]) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => PackageFormDialog(package: package),
    );
  }

  void _showAddPackageDialog(BuildContext context) {
    final name = TextEditingController();
    final location = TextEditingController();
    final price = TextEditingController();
    final duration = TextEditingController();
    final description = TextEditingController();
    final imageUrl = TextEditingController();
    final lat = TextEditingController();
    final lng = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: GlassContainer(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Add New Package',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        _buildDialogField(name, 'Package Name'),
                        _buildDialogField(location, 'Location'),
                        _buildDialogField(price, 'Price', isNumeric: true),
                        _buildDialogField(duration, 'Duration (e.g. 5 Days)'),
                        _buildDialogField(lat, 'Latitude', isNumeric: true),
                        _buildDialogField(lng, 'Longitude', isNumeric: true),
                        _buildDialogField(imageUrl, 'Image URL'),
                        _buildDialogField(description, 'Description', isMultiline: true),
                        const SizedBox(height: 24),
                        isLoading
                            ? const CircularProgressIndicator(color: AppTheme.primaryBlue)
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 45),
                                ),
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    setDialogState(() => isLoading = true);
                                    try {
                                      final parsedPrice = int.tryParse(price.text) ?? 0;
                                      final parsedLat = double.tryParse(lat.text) ?? 0.0;
                                      final parsedLng = double.tryParse(lng.text) ?? 0.0;

                                      final payload = {
                                        'name': name.text.trim(),
                                        'location': location.text.trim(),
                                        'price': parsedPrice,
                                        'duration': duration.text.trim(),
                                        'description': description.text.trim(),
                                        'imageUrl': imageUrl.text.trim(),
                                        'locationCoordinates': GeoPoint(parsedLat, parsedLng),
                                        'rating': 0.0,
                                        'itinerary': [],
                                        'createdAt': FieldValue.serverTimestamp(),
                                      };

                                      await FirebaseFirestore.instance.collection('packages').add(payload);
                                      
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Package added successfully!')),
                                        );
                                      }
                                    } catch (e) {
                                      setDialogState(() => isLoading = false);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: const Text('Add Package'),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, {bool isNumeric = false, bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: isMultiline ? 3 : 1,
        keyboardType: isNumeric ? TextInputType.number : (isMultiline ? TextInputType.multiline : TextInputType.text),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryBlue)),
          errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
          focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Future<void> _deletePackage(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Package', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this package? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _packageService.deletePackage(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPackageDialog(context),
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<TravelPackage>>(
        stream: _packageService.getPackagesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          final packages = snapshot.data ?? [];

          if (packages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  const Text('No packages found', style: TextStyle(color: Colors.white70, fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('Create your first package to get started', style: TextStyle(color: Colors.white38)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final package = packages[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(package.imageUrl),
                          fit: BoxFit.cover,
                          onError: (_, __) => const Icon(Icons.broken_image, color: Colors.white24),
                        ),
                      ),
                    ),
                    title: Text(
                      package.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${package.location} • \$${package.price}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue, size: 22),
                          onPressed: () => _showPackageForm(package),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                          onPressed: () => _deletePackage(package.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
