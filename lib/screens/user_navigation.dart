import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homeowners/screens/account/settings.dart';
import 'emergency/emergency_screen.dart';
import 'home/home_screen.dart';


class UserNavigation extends StatefulWidget {
  @override
  _UserNavigationState createState() => _UserNavigationState();
}

class _UserNavigationState extends State<UserNavigation> {
  int _selectedIndex = 0; // Default selected tab is Home
  final List<Widget> _screens = [
    HomePage(),
    EmergencyScreen(),
    AccountScreen(),
  ];

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0; // Set Home as selected first
      });
      return Future.value(false);
    } else {
      bool exitApp = await _showExitDialog();
      return exitApp;
    }
  }

  Future<bool> _showExitDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit App'),
        content: Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Exit'),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _screens[_selectedIndex], // Display selected screen
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning),
              label: 'Emergency',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
