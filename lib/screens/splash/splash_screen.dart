import 'package:flutter/material.dart';
import 'package:travelsphere/services/auth_service.dart';
import 'package:travelsphere/app/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Add a minimum delay for the splash screen visibility
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final user = _authService.currentUser;
    if (user != null) {
      Navigator.pushReplacementNamed(context, Routes.userDashboard);
    } else {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.public,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              'TravelSphere',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
             const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
