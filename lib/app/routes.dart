import 'package:flutter/material.dart';
import 'package:travelsphere/screens/splash/splash_screen.dart';
import 'package:travelsphere/screens/auth/login_screen.dart';
import 'package:travelsphere/screens/auth/signup_screen.dart';
import 'package:travelsphere/screens/auth/forgot_password_screen.dart';
import 'package:travelsphere/screens/user/user_dashboard.dart';
import 'package:travelsphere/screens/user/destination/premium_destination_screen.dart';
import 'package:travelsphere/screens/admin/admin_dashboard_screen.dart';
import 'package:travelsphere/screens/user/profile/profile_screen.dart';
import 'package:travelsphere/screens/user/my_trips/my_trips_screen.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String userDashboard = '/user-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String packageDetails = '/package-details';
  static const String budgetPlanner = '/budget-planner';
  static const String itineraryView = '/itinerary';
  static const String myTrips = '/my-trips';
  static const String profile = '/profile';
  static const String managePackages = '/admin/packages';
  static const String managePlaces = '/admin/places';
  static const String managePricing = '/admin/pricing';
  static const String admin = '/admin';
  static const String premiumDestination = '/premium-destination'; // Added route

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case userDashboard:
        return MaterialPageRoute(builder: (_) => const UserDashboard());
      case premiumDestination:
        return MaterialPageRoute(builder: (_) => const PremiumDestinationScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case myTrips:
        return MaterialPageRoute(builder: (_) => const MyTripsScreen());
      case admin:
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      
      // Placeholder routes for Phase 2
      case packageDetails:
      case budgetPlanner:
      case itineraryView:
      case managePackages:
      case managePlaces:
      case managePricing:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(settings.name ?? 'Unknown Route'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Coming in Phase 2'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
