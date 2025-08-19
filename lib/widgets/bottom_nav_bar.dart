import 'package:flutter/material.dart';
import 'package:loan_app/core/theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          elevation: 2,
          backgroundColor: bottomNavBarColor, // Background color
          selectedItemColor: selectedIconColor, // <-- Add this line
          selectedIconTheme: IconThemeData(
            size: 24,
            color: selectedIconColor,
          ), // Active icon blue
          unselectedIconTheme: IconThemeData(
            size: 20,
            color: unSelectedIconColor, // Inactive icon gray
          ), // Inactive icon black
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            color: selectedIconColor,
            fontWeight: FontWeight.bold,
          ), // Reduce font size
          unselectedLabelStyle: TextStyle(fontSize: 12), // Reduce font size
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures labels show
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            backgroundColor: Colors.grey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Customer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_outlined),
            label: 'Loans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
          // BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}
