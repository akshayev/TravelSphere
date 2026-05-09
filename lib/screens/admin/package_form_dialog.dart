import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/models/package_model.dart';
import 'package:travelsphere/services/travel_package_service.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';
import 'package:travelsphere/screens/admin/admin_map_picker_screen.dart';

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
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  String? _imageUrl;
  File? _selectedImageFile;
  bool _isUploadingImage = false;

  LatLng? _selectedCoordinates;

  List<Map<String, TextEditingController>> _itineraryControllers = [];

  final List<String> _availableInclusions = [
    'Flights', 'Hotels', 'Transfers', 'Meals', 'Sightseeing', 'Visa',
    'Guide', 'Insurance', 'Activities', 'Wi-Fi', 'Breakfast', 'Welcome Drink'
  ];
  List<String> _selectedInclusions = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.package?.name ?? '');
    _priceController = TextEditingController(text: widget.package?.price.toString() ?? '');
    _durationController = TextEditingController(text: widget.package?.duration ?? '');
    _locationController = TextEditingController(text: widget.package?.location ?? '');
    _descriptionController = TextEditingController(text: widget.package?.description ?? '');

    _imageUrl = widget.package?.imageUrl;
    _selectedCoordinates = widget.package?.locationCoordinates;
    _selectedInclusions = List.from(widget.package?.includedItems ?? []);

    final itinerary = widget.package?.itinerary ?? [];
    if (itinerary.isEmpty) {
      _itineraryControllers.add({
        'title': TextEditingController(),
        'description': TextEditingController(),
      });
    } else {
      for (var day in itinerary) {
        _itineraryControllers.add({
          'title': TextEditingController(text: day['title']),
          'description': TextEditingController(text: day['description']),
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    for (var c in _itineraryControllers) {
      c['title']?.dispose();
      c['description']?.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
        // We will just preview the image locally and upload it when saving
        // This gives immediate visual feedback without waiting for network.
      });
    }
  }

  Future<void> _pickLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminMapPickerScreen(initialLocation: _selectedCoordinates),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCoordinates = result;
      });
    }
  }

  Future<void> _savePackage() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrl == null && _selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload an image')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_selectedImageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('package_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        final uploadTask = storageRef.putFile(_selectedImageFile!);
        final snapshot = await uploadTask;
        _imageUrl = await snapshot.ref.getDownloadURL();
      }

      final itinerary = _itineraryControllers
          .where((c) => c['title']!.text.trim().isNotEmpty && c['description']!.text.trim().isNotEmpty)
          .map((c) => {
                'title': c['title']!.text.trim(),
                'description': c['description']!.text.trim(),
              })
          .toList();

      final updatedPackage = TravelPackage(
        id: widget.package?.id ?? '', // ID handled by service for new docs
        name: _nameController.text.trim(),
        imageUrl: _imageUrl!,
        price: int.parse(_priceController.text),
        rating: widget.package?.rating ?? 4.5,
        duration: _durationController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        itinerary: itinerary,
        includedItems: _selectedInclusions,
        locationCoordinates: _selectedCoordinates,
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
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Upload
                      Center(
                        child: GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                              image: _selectedImageFile != null
                                  ? DecorationImage(image: FileImage(_selectedImageFile!), fit: BoxFit.cover)
                                  : _imageUrl != null
                                      ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                                      : null,
                            ),
                            child: _imageUrl == null && _selectedImageFile == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, color: Colors.white54, size: 40),
                                      SizedBox(height: 8),
                                      Text('Tap to upload image', style: TextStyle(color: Colors.white54)),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(_nameController, 'Package Name', Icons.title),
                      _buildTextField(_priceController, 'Price (USD)', Icons.attach_money, isNumeric: true),
                      _buildTextField(_durationController, 'Duration (e.g. 5 Days)', Icons.timer),
                      _buildTextField(_descriptionController, 'Description', Icons.description, isMultiline: true),
                      
                      // Location Map Picker
                      const Text('Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      _buildTextField(_locationController, 'Location Text (e.g. Paris)', Icons.location_city),
                      OutlinedButton.icon(
                        onPressed: _pickLocation,
                        icon: const Icon(Icons.map, color: Colors.cyanAccent),
                        label: Text(_selectedCoordinates == null ? 'Pick on Map' : 'Location Selected! Tap to change', style: const TextStyle(color: Colors.cyanAccent)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.cyanAccent)),
                      ),
                      const SizedBox(height: 16),

                      // What's Included
                      const Text("What's Included", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _availableInclusions.map((item) {
                          final isSelected = _selectedInclusions.contains(item);
                          return FilterChip(
                            label: Text(item, style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                            selected: isSelected,
                            selectedColor: Colors.cyanAccent,
                            checkmarkColor: Colors.black,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  _selectedInclusions.add(item);
                                } else {
                                  _selectedInclusions.remove(item);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Itinerary
                      const Text('Itinerary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _itineraryControllers.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildTextField(
                                        _itineraryControllers[index]['title']!,
                                        'Day ${index + 1} Title (e.g., Arrival in Paris)',
                                        Icons.today,
                                        bottomPadding: 8,
                                      ),
                                      _buildTextField(
                                        _itineraryControllers[index]['description']!,
                                        'Day ${index + 1} Description',
                                        Icons.description,
                                        isMultiline: true,
                                        bottomPadding: 0,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      _itineraryControllers[index]['title']?.dispose();
                                      _itineraryControllers[index]['description']?.dispose();
                                      _itineraryControllers.removeAt(index);
                                    });
                                  },
                                )
                              ],
                            ),
                          );
                        },
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _itineraryControllers.add({
                              'title': TextEditingController(),
                              'description': TextEditingController(),
                            });
                          });
                        },
                        icon: const Icon(Icons.add, color: AppTheme.primaryBlue),
                        label: const Text('Add Day', style: TextStyle(color: AppTheme.primaryBlue)),
                      ),
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
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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
    double bottomPadding = 16.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: isMultiline ? 3 : 1,
        keyboardType: isNumeric ? TextInputType.number : (isMultiline ? TextInputType.multiline : TextInputType.text),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: AppTheme.primaryBlue, size: 20),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
