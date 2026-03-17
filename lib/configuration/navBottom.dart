import 'package:Aturuang/configuration/theme_config.dart';
import 'package:Aturuang/pages/home.dart';
import 'package:Aturuang/pages/profile.dart';
import 'package:flutter/material.dart';

class NavigationBarDemo extends StatefulWidget {
  const NavigationBarDemo({super.key});

  @override
  _NavigationBarDemoState createState() => _NavigationBarDemoState();
}

class _NavigationBarDemoState extends State<NavigationBarDemo> {
  int _currentIndex = 0;

  final List<Widget> _page = [
    const HomePage(),
    const ProfilePage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _page[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
            onTap: onTabTapped,
            currentIndex: _currentIndex,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
                backgroundColor: Colors.white,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
                backgroundColor: Colors.white,
              )
            ],
            backgroundColor: primaryColor,
            unselectedItemColor: secondaryColor,
            selectedItemColor: Colors.white,
            selectedIconTheme: IconThemeData(color: Colors.white)));
  }
}
