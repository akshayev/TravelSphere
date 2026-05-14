import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/services/user_service.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';

class EditProfileSheet extends StatefulWidget {
  final String displayName;
  final String phoneNumber;
  final String bio;
  final int? birthYear;

  const EditProfileSheet({
    super.key,
    required this.displayName,
    required this.phoneNumber,
    required this.bio,
    this.birthYear,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final UserService _userService = UserService();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _bioCtrl;
  int? _selectedYear;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.displayName);
    _phoneCtrl = TextEditingController(text: widget.phoneNumber);
    _bioCtrl = TextEditingController(text: widget.bio);
    _selectedYear = widget.birthYear;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _snack('Name cannot be empty.', Colors.orange);
      return;
    }
    setState(() => _saving = true);
    try {
      await _userService.updateProfileFields(
        displayName: _nameCtrl.text,
        phoneNumber: _phoneCtrl.text,
        bio: _bioCtrl.text,
        birthYear: _selectedYear,
      );
      if (mounted) {
        Navigator.pop(context);
        _snack('Profile updated!', AppTheme.primaryBlue);
      }
    } catch (e) {
      setState(() => _saving = false);
      _snack('Failed: ${e.toString()}', Colors.redAccent);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(
        80, (i) => DateTime.now().year - 10 - i);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: GlassContainer(
        borderRadius: 28,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Edit Profile',
                style: TextStyle(color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Update your personal information',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13)),
            const SizedBox(height: 24),
            _field(_nameCtrl, 'Display Name', Icons.person_outline),
            const SizedBox(height: 14),
            _field(_phoneCtrl, 'Phone Number', Icons.phone_outlined,
                inputType: TextInputType.phone),
            const SizedBox(height: 14),
            // Birth Year dropdown
            _dropdownField(years),
            const SizedBox(height: 14),
            _field(_bioCtrl, 'Bio / Travel Interests', Icons.edit_note_outlined,
                maxLines: 3),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(child: _cancelBtn()),
              const SizedBox(width: 12),
              Expanded(child: _saveBtn()),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.35), width: 1.5),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: inputType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        cursorColor: AppTheme.primaryBlue,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 14),
          prefixIcon: Icon(icon, color: AppTheme.primaryBlue, size: 20),
        ),
      ),
    );
  }

  Widget _dropdownField(List<int> years) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.35), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(children: [
        const Icon(Icons.cake_outlined, color: AppTheme.primaryBlue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedYear,
              hint: const Text('Birth Year',
                  style: TextStyle(color: Colors.white38, fontSize: 14)),
              dropdownColor: const Color(0xFF1A2340),
              iconEnabledColor: AppTheme.primaryBlue,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              isExpanded: true,
              items: years.map((y) => DropdownMenuItem(
                value: y,
                child: Text(y.toString()),
              )).toList(),
              onChanged: (v) => setState(() => _selectedYear = v),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _cancelBtn() => TextButton(
    onPressed: _saving ? null : () => Navigator.pop(context),
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
    ),
    child: Text('Cancel',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
  );

  Widget _saveBtn() => ElevatedButton(
    onPressed: _saving ? null : _save,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryBlue,
      disabledBackgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
    child: _saving
        ? const SizedBox(height: 18, width: 18,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
        : const Text('Save Changes',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
  );
}
