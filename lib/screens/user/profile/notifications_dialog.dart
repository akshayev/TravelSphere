import 'package:flutter/material.dart';

import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/services/user_service.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';

class NotificationsDialog extends StatefulWidget {
  final Map<String, dynamic> userData;
  const NotificationsDialog({super.key, required this.userData});

  @override
  State<NotificationsDialog> createState() => _NotificationsDialogState();
}

class _NotificationsDialogState extends State<NotificationsDialog> {
  final UserService _userService = UserService();
  late bool _push;
  late bool _email;
  late bool _promo;

  @override
  void initState() {
    super.initState();
    _push  = widget.userData['notifPush']  ?? true;
    _email = widget.userData['notifEmail'] ?? false;
    _promo = widget.userData['notifPromo'] ?? true;
  }

  Future<void> _toggle({bool? push, bool? email, bool? promo}) async {
    try {
      await _userService.updateNotificationPrefs(
        push: push, email: email, promo: promo);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to save preference.'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(),
            const SizedBox(height: 16),
            _tile(
              icon: Icons.notifications_active_outlined,
              title: 'Push Notifications',
              subtitle: 'Booking updates & trip alerts',
              value: _push,
              onChanged: (v) {
                setState(() => _push = v);
                _toggle(push: v);
              },
            ),
            _tile(
              icon: Icons.email_outlined,
              title: 'Email Alerts',
              subtitle: 'Itinerary confirmations & receipts',
              value: _email,
              onChanged: (v) {
                setState(() => _email = v);
                _toggle(email: v);
              },
            ),
            _tile(
              icon: Icons.local_offer_outlined,
              title: 'Promotional Offers',
              subtitle: 'Deals, discounts & new packages',
              value: _promo,
              onChanged: (v) {
                setState(() => _promo = v);
                _toggle(promo: v);
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text(
                  'Preferences are saved automatically.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                )),
              ]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Row(children: [
    Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.notifications_outlined, color: AppTheme.primaryBlue, size: 22),
    ),
    const SizedBox(width: 14),
    const Text('Notifications',
        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
  ]);

  Widget _tile({required IconData icon, required String title,
      required String subtitle, required bool value,
      required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppTheme.primaryBlue, size: 22),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        value: value,
        activeTrackColor: AppTheme.primaryBlue,
        activeThumbColor: Colors.white,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
