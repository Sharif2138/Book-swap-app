import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We listen to the provider to display the user's email
    final authProvider = context.watch<AuthProvider>();
    final email = authProvider.user?.email ?? 'your email';

    // We use listen: false for actions to avoid unnecessary rebuilds
    final authActionProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Account'),
        backgroundColor: const Color.fromARGB(255, 1, 6, 37),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.email_outlined,
                size: 80,
                color: Colors.blueGrey,
              ),
              const SizedBox(height: 24),
              const Text(
                'Verification Link Sent!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 1, 6, 37),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please check your email ($email) to complete your registration. You might need to check your spam folder.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 40),

              // --- 1. Reload Button (CRITICAL) ---
              // This reloads the Firebase User and checks 'isEmailVerified'.
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('I Have Verified My Email (Reload)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: const Color.fromARGB(255, 1, 6, 37),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                onPressed: () async {
                  await authActionProvider.reloadUser();
                  // The AuthWrapper will automatically navigate away if verification is true
                },
              ),
              const SizedBox(height: 20),

              // --- 2. Resend Link Button ---
              TextButton(
                onPressed: () async {
                  try {
                    await authActionProvider.sendEmailVerification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification link re-sent!'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: const Text(
                  'Resend Verification Email',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- 3. Sign Out Button ---
              TextButton(
                onPressed: () => authActionProvider.signOut(),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
