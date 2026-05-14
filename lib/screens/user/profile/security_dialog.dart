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

  Future<void> _sendPasswordReset(BuildContext context) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    Navigator.pop(context);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text('Password reset email sent to $email')),
          ]),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
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
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            const Text('Delete Account?',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('This action is permanent. All your data will be erased.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 14)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
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
    final emailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

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
              child: const Icon(Icons.security, color: Colors.greenAccent, size: 22),
            ),
            const SizedBox(width: 14),
            const Text('Security', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 20),

          // Email verification status
          _infoTile(
            icon: emailVerified ? Icons.verified_outlined : Icons.warning_amber_outlined,
            iconColor: emailVerified ? Colors.greenAccent : Colors.orangeAccent,
            title: 'Email Verification',
            subtitle: emailVerified ? 'Verified: $email' : 'Not verified — check your inbox',
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
            subtitle: 'Send a reset link to your email',
            onTap: () => _sendPasswordReset(context),
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
              child: Text('Close', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _infoTile({required IconData icon, required Color iconColor,
      required String title, required String subtitle}) {
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
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12)),
        ])),
      ]),
    );
  }

  Widget _actionTile({required IconData icon, required Color iconColor,
      required String title, required String subtitle, required VoidCallback onTap,
      Color titleColor = Colors.white}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 22),
        title: Text(title, style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white.withValues(alpha: 0.3)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
