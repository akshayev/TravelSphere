import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for exception handling
import '../../app/routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/social_button.dart';
import '../../widgets/common/glass_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (mounted) {
          Navigator.pushReplacementNamed(context, Routes.userDashboard);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getErrorMessage(e)),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, Routes.userDashboard);
      } else if (mounted) {
          // Google sign in cancelled or failed silently
             setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fallback
      body: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 2. Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // 3. Glass Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo and Title
                      Icon(
                        Icons.travel_explore,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 28,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue your journey',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 48),

                      // Email Field
                      CustomTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        fillColor: Colors.white.withOpacity(0.1),
                        textColor: Colors.white,
                        borderColor: Colors.white.withOpacity(0.3),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      CustomTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        controller: _passwordController,
                        fillColor: Colors.white.withOpacity(0.1),
                        textColor: Colors.white,
                        borderColor: Colors.white.withOpacity(0.3),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                             Navigator.pushNamed(context, Routes.forgotPassword);
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.cyanAccent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      CustomButton(
                        text: 'Login',
                        onPressed: _handleLogin,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.white24)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(color: Colors.white60),
                            ),
                          ),
                          const Expanded(child: Divider(color: Colors.white24)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Google Sign In
                      SocialButton(
                        text: 'Sign in with Google',
                        icon: Icons.g_mobiledata, 
                        onPressed: _handleGoogleLogin,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                      ),
                      const SizedBox(height: 24),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: () {
                               Navigator.pushNamed(context, Routes.signup);
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.cyanAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'invalid-email':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Invalid email or password.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Please check your internet connection.'; 
        default:
          return 'Login failed: ${error.message}';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
