import 'package:flutter/material.dart';
import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/models/package_model.dart';
import 'package:travelsphere/services/travel_package_service.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';

class PackageFormDialog extends StatefulWidget {
  final TravelPackage? package;

  const PackageFormDialog({super.key, this.package});

  @override
  State<PackageFormDialog> createState() => _PackageFormDialogState();
}

class _PackageFormDialogState extends State<PackageFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _packageService = TravelPackageService();

  late TextEditingController _nameController;
  late TextEditingController _imageUrlController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _itineraryController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.package?.name ?? '');
    _imageUrlController = TextEditingController(text: widget.package?.imageUrl ?? '');
    _priceController = TextEditingController(text: widget.package?.price.toString() ?? '');
    _durationController = TextEditingController(text: widget.package?.duration ?? '');
    _locationController = TextEditingController(text: widget.package?.location ?? '');
    _descriptionController = TextEditingController(text: widget.package?.description ?? '');
    _itineraryController = TextEditingController(text: widget.package?.itinerary.join(', ') ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _itineraryController.dispose();
    super.dispose();
  }

  Future<void> _savePackage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedPackage = TravelPackage(
        id: widget.package?.id ?? '', // ID handled by service for new docs
        name: _nameController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        price: int.parse(_priceController.text),
        rating: widget.package?.rating ?? 4.5, // Default rating for now
        duration: _durationController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        itinerary: _itineraryController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      );

      if (widget.package == null) {
        await _packageService.addPackage(updatedPackage);
      } else {
        await _packageService.updatePackage(updatedPackage);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.package == null ? 'Package added successfully!' : 'Package updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.package == null ? 'Create New Package' : 'Edit Package',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField(_nameController, 'Package Name', Icons.title),
                      _buildTextField(_locationController, 'Location', Icons.location_on),
                      _buildTextField(_priceController, 'Price (USD)', Icons.attach_money, isNumeric: true),
                      _buildTextField(_durationController, 'Duration (e.g. 5 Days)', Icons.timer),
                      _buildTextField(_imageUrlController, 'Image URL', Icons.image, isUrl: true),
                      _buildTextField(_descriptionController, 'Description', Icons.description, isMultiline: true),
                      _buildTextField(_itineraryController, 'Itinerary (comma separated)', Icons.list),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _savePackage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumeric = false,
    bool isMultiline = false,
    bool isUrl = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: isMultiline ? 4 : 1,
        keyboardType: isNumeric ? TextInputType.number : (isMultiline ? TextInputType.multiline : TextInputType.text),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: AppTheme.primaryBlue, size: 20),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Please enter $label';
          if (isNumeric && int.tryParse(value) == null) return 'Enter a valid number';
          return null;
        },
      ),
    );
  }
}
