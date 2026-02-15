import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../app/routes.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleSignOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.dashboard,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome, User!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your journey starts here.',
              style: TextStyle(color: Colors.grey),
            ),
             const SizedBox(height: 32),
             ElevatedButton.icon(
              onPressed: () => _handleSignOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
             ),
          ],
        ),
      ),
    );
  }
}
