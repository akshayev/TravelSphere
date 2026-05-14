import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/app/routes.dart';
import 'package:travelsphere/services/auth_service.dart';
import 'package:travelsphere/services/user_service.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';
import 'package:travelsphere/screens/user/profile/edit_profile_sheet.dart';
import 'package:travelsphere/screens/user/profile/notifications_dialog.dart';
import 'package:travelsphere/screens/user/profile/security_dialog.dart';
import 'package:travelsphere/screens/user/profile/help_support_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isEnsuringProfile = false;
  String? _profileSetupError;

  // ── Sign Out ───────────────────────────────────────────────────────────────
  Future<void> _handleSignOut() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
    }
  }

  // ── Profile Image ──────────────────────────────────────────────────────────
  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 75);
      if (image == null) return;
      setState(() => _isUploading = true);
      final String? url = await _userService.uploadProfileImage(File(image.path));
      if (url != null) {
        await _userService.updateUserProfile(photoUrl: url);
        _snack('Profile picture updated!', Colors.green);
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      _snack('Error: ${e.toString()}', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isUploading = false);
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

  void _triggerProfileSetup() {
    final authUser = _userService.firebaseUser;
    if (authUser == null || _isEnsuringProfile) return;

    _isEnsuringProfile = true;
    _profileSetupError = null;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() {});
      try {
        await _userService.ensureUserDocument(authUser);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _profileSetupError = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isEnsuringProfile = false;
          });
        }
      }
    });
  }

  // ── Open Edit Profile Sheet ────────────────────────────────────────────────
  void _openEditProfile(Map<String, dynamic> userData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: EditProfileSheet(
          displayName: userData['displayName'] ?? '',
          phoneNumber: userData['phoneNumber'] ?? '',
          bio: userData['bio'] ?? '',
          birthYear: userData['birthYear'] as int?,
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userService.streamUserDoc(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
          }
          if (snapshot.hasError) {
            return _errorState(snapshot.error.toString());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            final authUser = _userService.firebaseUser;
            if (authUser == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
              });
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
            }
            if (_profileSetupError == null && !_isEnsuringProfile) {
              _triggerProfileSetup();
            }
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppTheme.primaryBlue),
                  const SizedBox(height: 16),
                  const Text('Setting up your profile…', style: TextStyle(color: Colors.white70)),
                  if (_profileSetupError != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'We could not finish profile setup. Please retry.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.redAccent.withValues(alpha: 0.9)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _profileSetupError = null;
                        });
                        _triggerProfileSetup();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String displayName = userData['displayName'] ?? 'Traveler';
          final String email = userData['email'] ?? '';
          final String? photoUrl = userData['photoURL'];
          final String role = userData['role'] ?? 'user';

          return CustomScrollView(slivers: [
            // ── Profile Card
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  Stack(children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null || photoUrl.isEmpty
                          ? const Icon(Icons.person, size: 50, color: AppTheme.primaryBlue)
                          : null,
                    ),
                    if (_isUploading)
                      Positioned.fill(child: Container(
                        decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 3, color: AppTheme.primaryBlue)),
                      )),
                    Positioned(bottom: 0, right: 0,
                      child: GestureDetector(
                        onTap: _isUploading ? null : _pickAndUploadImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Text(displayName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(email,
                      style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
                  if ((userData['bio'] as String?)?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(userData['bio'],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.55))),
                  ],
                ]),
              ),
            )),

            // ── Options
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                _option(Icons.person_outline, 'Edit Profile',
                    () => _openEditProfile(userData)),
                _option(Icons.notifications_none, 'Notifications',
                    () => showDialog(context: context,
                        builder: (_) => NotificationsDialog(userData: userData))),
                _option(Icons.security, 'Security',
                    () => showDialog(context: context,
                        builder: (_) => const SecurityDialog())),
                _option(Icons.help_outline, 'Help & Support',
                    () => showDialog(context: context,
                        builder: (_) => const HelpSupportDialog())),
                if (role == 'admin')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/admin'),
                      child: const GlassContainer(
                        child: ListTile(
                          leading: Icon(Icons.admin_panel_settings, color: Colors.white),
                          title: Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
                          trailing: Icon(Icons.chevron_right, color: Colors.white54),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: _handleSignOut,
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text('Sign Out',
                      style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                ),
                const SizedBox(height: 40),
              ]),
            )),
          ]);
        },
      ),
    );
  }

  Widget _option(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
            ),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.3), size: 16),
          ]),
        ),
      ),
    );
  }

  Widget _errorState(String error) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 48),
    const SizedBox(height: 16),
    const Text('Could not load profile.',
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    Text(error, textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 11)),
    const SizedBox(height: 20),
    TextButton.icon(
      onPressed: _handleSignOut,
      icon: const Icon(Icons.logout, color: Colors.redAccent),
      label: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
    ),
  ]));
}
