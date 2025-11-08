import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_swap_app/providers/auth_provider.dart';
import 'package:book_swap_app/ui/screens/protected_screens/bottom_nav.dart';
import 'package:book_swap_app/ui/screens/onboarding/email_verification.dart';
import 'package:book_swap_app/ui/screens/onboarding/home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // 1. Show Loading Screen
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 210, 231, 23),
          ),
        ),
      );
    }

    // 2. If Authenticated
    if (authProvider.isAuthenticated) {
      // 3. CHECK EMAIL VERIFICATION (CRITICAL ASSIGNMENT REQUIREMENT) ⚠️
      // If the user is logged in but their email is not verified,
      // direct them to the dedicated verification screen.
      if (!authProvider.isEmailVerified) {
        return const EmailVerificationScreen();
      }

      // 4. If logged in AND verified, show the main application content (Bottom Navigation)
      // Note: Use 'const BottomNav()' if all child screens are also constant,
      // but keeping it without 'const' prevents warnings about non-constant screens.
      return const BottomNav();
    }

    // 5. If NOT Authenticated, show the initial landing page
    return const HomePage();
  }
}