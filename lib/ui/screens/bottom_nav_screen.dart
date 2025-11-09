import 'package:flutter/material.dart';
import 'browse_listings_screen.dart';
import 'swap_offers_screen.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int index = 0;

  // Remove 'const' if these screens are Stateful or rely on Providers internally
  final screens = [
    BrowseListingsScreen(),
    SwapOffersScreen(),
    ChatScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Preserve state with IndexedStack
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        backgroundColor: const Color.fromARGB(255, 1, 6, 37),
        selectedItemColor: const Color.fromARGB(
          255,
          214,
          224,
          31,
        ), // yellow accent
        unselectedItemColor: Colors.white54,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Offers',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
