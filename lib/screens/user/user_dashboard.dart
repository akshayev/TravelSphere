import 'package:flutter/material.dart';
import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/screens/user/home/home_screen.dart';
import 'package:travelsphere/screens/user/planner/trip_planner_screen.dart';
import 'package:travelsphere/screens/user/my_trips/my_trips_screen.dart';
import 'package:travelsphere/screens/user/profile/profile_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(), 
    const TripPlannerScreen(), 
    const MyTripsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        backgroundColor: AppTheme.backgroundDark,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_location_alt),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'My Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
