import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/widgets/common/custom_button.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';
import 'package:travelsphere/services/itinerary_generator.dart';
import 'package:travelsphere/screens/user/planner/generated_itinerary_screen.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  // Form State
  String? _selectedDestination;
  DateTime? _startDate;
  double _duration = 3;
  double _budget = 5000;
  int _travelers = 2;

  final List<String> _destinations = [
    'Goa',
    'Kerala',
    'Himachal Pradesh',
    'Rajasthan',
    'Andaman',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Plan Your Trip',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?q=80&w=2021&auto=format&fit=crop', // Travel planning / Map vibe
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.black),
              errorWidget: (context, url, error) => Container(color: Colors.black),
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
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          // 3. Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Text
                  const Text(
                    'Tell us your preferences',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We will generate a personalized itinerary for you.',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  // 1. Destination
                  _buildSectionLabel('Where do you want to go?'),
                  const SizedBox(height: 12),
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDestination,
                        hint: Text('Select Destination', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                        isExpanded: true,
                        dropdownColor: Colors.grey[900], // Dark dropdown background
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.cyanAccent),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        items: _destinations.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDestination = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Start Date
                  _buildSectionLabel('When are you going?'),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: GlassContainer(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _startDate == null
                                ? 'Select Start Date'
                                : DateFormat('EEE, d MMM yyyy').format(_startDate!),
                            style: TextStyle(
                              color: _startDate == null ? Colors.white.withOpacity(0.6) : Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.cyanAccent, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Duration
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Duration', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                              '${_duration.round()} Days',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyanAccent,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.cyanAccent,
                            inactiveTrackColor: Colors.white.withOpacity(0.2),
                            thumbColor: Colors.white,
                            overlayColor: Colors.cyanAccent.withOpacity(0.2),
                            trackHeight: 4.0,
                          ),
                          child: Slider(
                            value: _duration,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: '${_duration.round()} Days',
                            onChanged: (value) {
                              setState(() {
                                _duration = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Budget
                   GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Budget per Person', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                              '₹${_budget.round()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyanAccent,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.cyanAccent,
                            inactiveTrackColor: Colors.white.withOpacity(0.2),
                            thumbColor: Colors.white,
                            overlayColor: Colors.cyanAccent.withOpacity(0.2),
                            trackHeight: 4.0,
                          ),
                          child: Slider(
                            value: _budget,
                            min: 1000,
                            max: 50000,
                            divisions: 49,
                            label: '₹${_budget.round()}',
                            onChanged: (value) {
                              setState(() {
                                _budget = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Travelers
                  _buildSectionLabel('Who is traveling?'),
                  const SizedBox(height: 12),
                  GlassContainer(
                     width: double.infinity,
                     padding: const EdgeInsets.all(12),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         const Text('Travelers', style: TextStyle(fontSize: 16, color: Colors.white)),
                         Row(
                           children: [
                             _buildIconButton(Icons.remove, () {
                               if (_travelers > 1) {
                                 setState(() => _travelers--);
                               }
                             }),
                             Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 16),
                               child: Text(
                                 '$_travelers',
                                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                               ),
                             ),
                             _buildIconButton(Icons.add, () {
                               if (_travelers < 10) {
                                 setState(() => _travelers++);
                               }
                             }),
                           ],
                         ),
                       ],
                     ),
                  ),
                  const SizedBox(height: 48),

                  // Generate Button
                  CustomButton(
                    text: 'Generate Itinerary ✨',
                    onPressed: () async {
                      if (_selectedDestination == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a destination')),
                        );
                        return;
                      }
                      if (_startDate == null) {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a start date')),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const Center(
                            child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                          );
                        },
                      );

                      try {
                        // Generate Logic
                        final results = await ItineraryGenerator.generateTrip(
                          category: _selectedDestination ?? 'Any',
                          days: _duration.round(),
                          budget: _budget,
                          travelers: _travelers,
                        );

                        if (context.mounted) {
                          Navigator.pop(context); // close loading
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GeneratedItineraryScreen(
                                results: results,
                                totalBudget: _budget,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                         if (context.mounted) {
                           Navigator.pop(context);
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Failed to generate trip: \$e')),
                           );
                         }
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: Colors.white),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark( // Dark theme for date picker
              primary: Colors.cyanAccent,
              onPrimary: Colors.black,
              surface: Color(0xFF212121),
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.grey[900]),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }
}
