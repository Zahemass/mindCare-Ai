import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../providers/navigation_provider.dart';
import 'home/home_screen.dart';
import 'self_care/self_care_screen.dart';
import 'resources/resources_screen.dart';
import 'placeholders.dart' hide SelfCareScreen;
import 'profile/profile_screen.dart';
import 'chat/chat_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatScreen(showBackButton: false),
    const SelfCareScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navProvider = context.watch<NavigationProvider>();

    return Scaffold(
      body: _screens[navProvider.selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? ThemeConfig.darkSurface : Colors.white,
          border: isDark
              ? const Border(top: BorderSide(color: ThemeConfig.darkBorder, width: 1))
              : null,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: navProvider.selectedIndex,
          onTap: (index) {
            navProvider.setIndex(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
          selectedItemColor: ThemeConfig.primaryTeal,
          unselectedItemColor: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.mutedText,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'AI Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement_outlined),
              activeIcon: Icon(Icons.self_improvement),
              label: 'Mind Care',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
