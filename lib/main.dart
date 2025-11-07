import 'package:book_swap_app/ui/screens/onboarding/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:book_swap_app/ui/screens/onboarding/home_page.dart';
import 'package:book_swap_app/ui/screens/onboarding/login_screen.dart';
import 'package:book_swap_app/ui/screens/protected screens/feed_screen.dart';
import 'package:book_swap_app/ui/screens/protected screens/chat_screen.dart';
import 'package:book_swap_app/ui/screens/protected screens/my_list_screen.dart';
import 'package:book_swap_app/ui/screens/protected screens/settings_screen.dart';
import 'package:book_swap_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: const BookSwap(),
    ),
  );
}

class BookSwap extends StatelessWidget {
  const BookSwap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Swap App',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const BottomNav(),
        '/login': (context) => const LoginScreen(),
        '/feed': (context) => const BrowseListingsScreen(),
        '/mylist': (context) => const MyListingsScreen(),
        '/chat': (context) => const ChatScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  // List of screens
  final List<Widget> _screens = const [
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
      bottomNavigationBar: SizedBox(
        height: 70.0,
        child: BottomNavigationBar(
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
      ),
    );
  }
}
