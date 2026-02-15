import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../../services/itinerary_generator.dart';
import 'generated_itinerary_screen.dart';

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
      appBar: AppBar(
        title: const Text(
          'Plan Your Trip',
          style: TextStyle(color: AppTheme.darkGray, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.darkGray),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Text
            const Text(
              'Tell us your preferences',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We will generate a personalized itinerary for you.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),

            // 1. Destination
            _buildSectionLabel('Where do you want to go?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDestination,
                  hint: const Text('Select Destination'),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryBlue),
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
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _startDate == null
                          ? 'Select Start Date'
                          : DateFormat('EEE, d MMM yyyy').format(_startDate!),
                      style: TextStyle(
                        color: _startDate == null ? Colors.grey[600] : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: AppTheme.primaryBlue, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionLabel('Duration'),
                Text(
                  '${_duration.round()} Days',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            Slider(
              value: _duration,
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: AppTheme.primaryBlue,
              label: '${_duration.round()} Days',
              onChanged: (value) {
                setState(() {
                  _duration = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // 4. Budget
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionLabel('Budget per Person'),
                Text(
                  '₹${_budget.round()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            Slider(
              value: _budget,
              min: 1000,
              max: 50000,
              divisions: 49,
              activeColor: AppTheme.primaryBlue,
              label: '₹${_budget.round()}',
              onChanged: (value) {
                setState(() {
                  _budget = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // 5. Travelers
            _buildSectionLabel('Who is traveling?'),
            const SizedBox(height: 12),
            Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: Colors.grey[100],
                 borderRadius: BorderRadius.circular(12),
               ),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   const Text('Travelers', style: TextStyle(fontSize: 16)),
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
                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              onPressed: () {
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

                // Generate Logic
                final results = ItineraryGenerator.generateTrip(
                  category: _selectedDestination ?? 'Any',
                  days: _duration.round(),
                  budget: _budget,
                  travelers: _travelers,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GeneratedItineraryScreen(
                      results: results,
                      totalBudget: _budget,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.darkGray,
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: AppTheme.primaryBlue),
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
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.darkGray,
            ),
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
