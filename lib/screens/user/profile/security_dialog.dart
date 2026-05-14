import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:travelsphere/app/routes.dart';
import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';

class SecurityDialog extends StatelessWidget {
  const SecurityDialog({super.key});

  String _lastSignIn() {
    final t = FirebaseAuth.instance.currentUser?.metadata.lastSignInTime;
    if (t == null) return 'Unknown';
    return DateFormat('dd MMM yyyy, hh:mm a').format(t.toLocal());
  }

  /// Returns true if the user signed up with email/password
  bool _hasPasswordProvider() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'password');
  }

  void _openChangePassword(BuildContext context) {
    if (!_hasPasswordProvider()) {
      // Google / other OAuth accounts — no password to change
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Your account uses Google Sign-In — password change is not available.'),
        backgroundColor: Colors.orangeAccent,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    Navigator.pop(context); // close security dialog first
    showDialog(context: context, builder: (_) => const _ChangePasswordDialog());
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            const Text('Delete Account?',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              'This action is permanent. All your data will be erased.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65), fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                  child: TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7))),
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('Delete',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )),
            ]),
          ]),
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await FirebaseAuth.instance.currentUser?.delete();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.login, (_) => false);
        }
      } on FirebaseAuthException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.code == 'requires-recent-login'
                ? 'Please sign out and sign in again before deleting your account.'
                : 'Error: ${e.message}'),
            backgroundColor: Colors.redAccent,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final emailVerified =
        FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    final hasPassword = _hasPasswordProvider();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Header
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.security,
                  color: Colors.greenAccent, size: 22),
            ),
            const SizedBox(width: 14),
            const Text('Security',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 20),

          // Email verification status
          _infoTile(
            icon: emailVerified
                ? Icons.verified_outlined
                : Icons.warning_amber_outlined,
            iconColor:
                emailVerified ? Colors.greenAccent : Colors.orangeAccent,
            title: 'Email Verification',
            subtitle: emailVerified
                ? 'Verified: $email'
                : 'Not verified — check your inbox',
          ),

          // Last sign-in
          _infoTile(
            icon: Icons.access_time_outlined,
            iconColor: AppTheme.primaryBlue,
            title: 'Last Sign-In',
            subtitle: _lastSignIn(),
          ),

          const SizedBox(height: 8),

          // Change password
          _actionTile(
            icon: Icons.lock_reset_outlined,
            iconColor: AppTheme.primaryBlue,
            title: 'Change Password',
            subtitle: hasPassword
                ? 'Update your password securely'
                : 'Not available for Google accounts',
            onTap: () => _openChangePassword(context),
          ),

          // Delete account
          _actionTile(
            icon: Icons.delete_forever_outlined,
            iconColor: Colors.redAccent,
            title: 'Delete Account',
            subtitle: 'Permanently remove all your data',
            onTap: () => _confirmDeleteAccount(context),
            titleColor: Colors.redAccent,
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7))),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _infoTile(
      {required IconData icon,
      required Color iconColor,
      required String title,
      required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 14),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12)),
            ])),
      ]),
    );
  }

  Widget _actionTile(
      {required IconData icon,
      required Color iconColor,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      Color titleColor = Colors.white}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 22),
        title: Text(title,
            style: TextStyle(
                color: titleColor,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 14, color: Colors.white.withValues(alpha: 0.3)),
        onTap: onTap,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// In-app Change Password Dialog
// ─────────────────────────────────────────────────────────────────────────────
class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _currentVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentCtrl.text.trim(),
      );

      // Re-authenticate first
      await user.reauthenticateWithCredential(cred);

      // Update to new password
      await user.updatePassword(_newCtrl.text.trim());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Password updated successfully!'),
          ]),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      String msg;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          msg = 'Current password is incorrect.';
          break;
        case 'weak-password':
          msg = 'New password is too weak. Use at least 6 characters.';
          break;
        case 'too-many-requests':
          msg = 'Too many attempts. Please try again later.';
          break;
        case 'requires-recent-login':
          msg =
              'Session expired. Please sign out and sign in again, then retry.';
          break;
        default:
          msg = 'Failed to update password. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    } catch (_) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An unexpected error occurred.'),
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
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Header
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lock_reset_outlined,
                    color: AppTheme.primaryBlue, size: 22),
              ),
              const SizedBox(width: 14),
              const Text('Change Password',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 24),

            // Current password
            _passwordField(
              controller: _currentCtrl,
              label: 'Current Password',
              visible: _currentVisible,
              onToggle: () =>
                  setState(() => _currentVisible = !_currentVisible),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your current password';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // New password
            _passwordField(
              controller: _newCtrl,
              label: 'New Password',
              visible: _newVisible,
              onToggle: () => setState(() => _newVisible = !_newVisible),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter a new password';
                if (v.length < 6) return 'Minimum 6 characters';
                if (v == _currentCtrl.text.trim()) {
                  return 'New password must differ from current';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirm password
            _passwordField(
              controller: _confirmCtrl,
              label: 'Confirm New Password',
              visible: _confirmVisible,
              onToggle: () =>
                  setState(() => _confirmVisible = !_confirmVisible),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your password';
                if (v != _newCtrl.text.trim()) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 28),

            // Buttons
            Row(children: [
              Expanded(
                  child: TextButton(
                onPressed:
                    _isLoading ? null : () => Navigator.pop(context),
                child: Text('Cancel',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7))),
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Update',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon:
            const Icon(Icons.lock_outline, color: AppTheme.primaryBlue),
        suffixIcon: IconButton(
          icon: Icon(
            visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.white54,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
