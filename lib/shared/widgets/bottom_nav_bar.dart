import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(
              color: Color(0xFF1B3A6B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconTheme: MaterialStateProperty.all(
            const IconThemeData(
              color: Color(0xFF1B3A6B),
            ),
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: AppStrings.navProfile,
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: AppStrings.navPolicy,
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: AppStrings.navNews,
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: AppStrings.navContact,
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: AppStrings.navNotification,
          ),
        ],
      ),
    );
  }
}
