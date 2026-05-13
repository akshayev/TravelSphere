import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/app/routes.dart';
import 'package:travelsphere/services/auth_service.dart';
import 'package:travelsphere/services/user_service.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // ── Sign Out ───────────────────────────────────────────────────────────────
  Future<void> _handleSignOut(BuildContext context) async {
    final authService = AuthService();
    await authService.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.login,
        (route) => false,
      );
    }
  }

  // ── Profile Image ──────────────────────────────────────────────────────────
  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      final File file = File(image.path);
      final String? downloadUrl = await _userService.uploadProfileImage(file);

      if (downloadUrl != null) {
        await _userService.updateUserProfile(photoUrl: downloadUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  // ── Edit Name Dialog ───────────────────────────────────────────────────────
  void _showEditNameDialog(String currentName) {
    final TextEditingController nameController =
        TextEditingController(text: currentName);
    bool isSaving = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: GlassContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: AppTheme.primaryBlue,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Edit Name',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Update your display name across the app.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ---- Name TextField
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: nameController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          cursorColor: AppTheme.primaryBlue,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: InputBorder.none,
                            hintText: 'Enter your name',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 15,
                            ),
                            prefixIcon: const Icon(
                              Icons.edit_outlined,
                              color: AppTheme.primaryBlue,
                              size: 20,
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => isSaving ? null : _saveName(
                            nameController.text,
                            dialogContext,
                            setDialogState,
                            (v) => isSaving = v,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ---- Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () => _saveName(
                                        nameController.text,
                                        dialogContext,
                                        setDialogState,
                                        (v) => isSaving = v,
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                disabledBackgroundColor:
                                    AppTheme.primaryBlue.withValues(alpha: 0.5),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Save',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Save Logic ─────────────────────────────────────────────────────────────
  Future<void> _saveName(
    String newName,
    BuildContext dialogContext,
    StateSetter setDialogState,
    void Function(bool) setIsSaving,
  ) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setDialogState(() => setIsSaving(true));

    try {
      await _userService.updateDisplayName(trimmed);

      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: AppTheme.primaryBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      setDialogState(() => setIsSaving(false));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userService.streamUserDoc(),
        builder: (context, snapshot) {
          // ── Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBlue));
          }

          // ── Error state (e.g. permission denied)
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      color: Colors.redAccent, size: 48),
                  const SizedBox(height: 16),
                  const Text('Could not load profile.',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 11),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () => _handleSignOut(context),
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text('Sign Out',
                        style: TextStyle(color: Colors.redAccent)),
                  )
                ],
              ),
            );
          }

          // ── No document: user is authenticated but doc was never created.
          // Auto-create it now.
          if (!snapshot.hasData || !snapshot.data!.exists) {
            final authUser = _userService.firebaseUser;
            if (authUser == null) {
              // Not signed in at all — go to login
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamedAndRemoveUntil(
                    context, Routes.login, (r) => false);
              });
              return const Center(
                  child:
                      CircularProgressIndicator(color: AppTheme.primaryBlue));
            }
            // Signed in but no doc — create it
            _userService.ensureUserDocument(authUser).catchError((_) {});
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryBlue),
                  SizedBox(height: 16),
                  Text('Setting up your profile…',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            );
          }


          final userData =
              snapshot.data!.data() as Map<String, dynamic>;
          final String displayName = userData['displayName'] ?? 'Traveler';
          final String email = userData['email'] ?? '';
          final String? photoUrl = userData['photoURL'];
          final String role = userData['role'] ?? 'user';

          return CustomScrollView(
            slivers: [
              // ---- Profile Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  AppTheme.primaryBlue.withValues(alpha: 0.1),
                              backgroundImage:
                                  photoUrl != null && photoUrl.isNotEmpty
                                      ? NetworkImage(photoUrl)
                                      : null,
                              child: photoUrl == null || photoUrl.isEmpty
                                  ? const Icon(Icons.person,
                                      size: 50, color: AppTheme.primaryBlue)
                                  : null,
                            ),
                            if (_isUploading)
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black45,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _isUploading
                                    ? null
                                    : _pickAndUploadImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ---- Options
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildProfileOption(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        onTap: () => _showEditNameDialog(displayName),
                      ),
                      _buildProfileOption(
                        icon: Icons.notifications_none,
                        title: 'Notifications',
                        onTap: () => _showNotificationsDialog(context),
                      ),
                      _buildProfileOption(
                        icon: Icons.security,
                        title: 'Security',
                        onTap: () => _showSecurityDialog(context),
                      ),
                      _buildProfileOption(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () => _showHelpDialog(context),
                      ),
                      if (role == 'admin')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/admin'),
                            child: const GlassContainer(
                              child: ListTile(
                                leading: Icon(Icons.admin_panel_settings,
                                    color: Colors.white),
                                title: Text('Admin Dashboard',
                                    style: TextStyle(color: Colors.white)),
                                trailing: Icon(Icons.chevron_right,
                                    color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: () => _handleSignOut(context),
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.redAccent, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Profile Option Tile ────────────────────────────────────────────────────
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(icon, color: AppTheme.primaryBlue, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Notifications Dialog ───────────────────────────────────────────────────
  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Push Notifications', style: TextStyle(color: Colors.white)),
                    value: true,
                    activeThumbColor: AppTheme.primaryBlue,
                    onChanged: (val) {},
                  ),
                  SwitchListTile(
                    title: const Text('Email Alerts', style: TextStyle(color: Colors.white)),
                    value: false,
                    activeThumbColor: AppTheme.primaryBlue,
                    onChanged: (val) {},
                  ),
                  SwitchListTile(
                    title: const Text('Promotional Offers', style: TextStyle(color: Colors.white)),
                    value: true,
                    activeThumbColor: AppTheme.primaryBlue,
                    onChanged: (val) {},
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                    child: const Text('Done', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  // ── Security Dialog ────────────────────────────────────────────────────────
  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Security Settings', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.password, color: AppTheme.primaryBlue),
                title: const Text('Change Password', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.verified_user, color: Colors.greenAccent),
                title: const Text('Two-Factor Auth', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Enabled', style: TextStyle(color: Colors.white54)),
                onTap: () {},
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close', style: TextStyle(color: Colors.white70)),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ── Help & Support Dialog ──────────────────────────────────────────────────
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Help & Support', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.email_outlined, color: AppTheme.primaryBlue),
                title: const Text('Contact Support', style: TextStyle(color: Colors.white)),
                subtitle: const Text('support@travelsphere.com', style: TextStyle(color: Colors.white54)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.help_center_outlined, color: Colors.orangeAccent),
                title: const Text('FAQs', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.article_outlined, color: Colors.cyanAccent),
                title: const Text('Terms & Conditions', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close', style: TextStyle(color: Colors.white70)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
