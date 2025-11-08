import 'package:flutter/material.dart';
import 'package:book_swap_app/ui/screens/protected_screens/feed_screen.dart';
import 'package:book_swap_app/ui/screens/protected_screens/chat_screen.dart';
import 'package:book_swap_app/ui/screens/protected_screens/my_list_screen.dart';
import 'package:book_swap_app/ui/screens/protected_screens/settings_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  // IMPORTANT: Using 'const' on these instances is generally safe for screen widgets
  // that don't take state-changing parameters.
  final List<Widget> _screens = const [
    // We assume 'FeedScreen' corresponds to 'Browse Listings'
    BrowseListingsScreen(),
    MyListingsScreen(),
    ChatScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            body: _screens[_selectedIndex],
            // Use standard BottomNavigationBar height, SizedBox is often unnecessary
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color.fromARGB(255, 1, 6, 37),
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.yellow,
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_books),
                  label: 'Browse',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.swap_horiz),
                  label: 'My List',
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