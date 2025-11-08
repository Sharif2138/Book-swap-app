import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // prefixed to avoid name conflict with local AuthProvider
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'ui/screens/onboarding/home_page.dart';
import 'ui/screens/onboarding/signup_screen.dart';
import 'ui/screens/onboarding/login_screen.dart';
import 'ui/screens/onboarding/auth_wrapper.dart';
// Note: You should uncomment these imports when creating the actual files
// import 'ui/screens/protected_screens/bottom_nav.dart';
// import 'ui/screens/onboarding/email_verification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // CRITICAL 1: StreamProvider listens to Firebase Auth changes in real-time.
        // This is what forces AuthWrapper to rebuild on login/logout.
        StreamProvider<fb_auth.User?>(
          create: (_) => fb_auth.FirebaseAuth.instance.authStateChanges(),
          initialData: null,
          catchError: (_, error) => null,
        ),

        // CRITICAL 2: ChangeNotifierProvider for your custom AuthProvider logic.
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(
          255,
          230,
          230,
          230,
        ), // A lighter default background
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: const Color.fromARGB(
            255,
            1,
            6,
            37,
          ), // Dark text on light backgrounds
        ),
      ),
      // AuthWrapper is the first screen shown, controlling all navigation
      home: const AuthWrapper(),
      routes: {
        '/home': (_) => const HomePage(),
        '/signup': (_) => const SignupScreen(),
        '/login': (_) => const LoginScreen(),
        // Ensure you add all protected screens and verification screen to routes if they are navigated to by name.
        // '/verification': (_) => const EmailVerificationScreen(),
        // '/app_home': (_) => const BottomNav(),
      },
    );
  }
}
