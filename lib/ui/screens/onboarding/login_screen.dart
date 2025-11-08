// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_swap_app/ui/widgets/book_icon.dart';
import 'package:book_swap_app/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    // We rely on context.read to access the provider for calling methods
    final authActions = context.read<AuthProvider>();

    // We explicitly set the loading state to false after the auth stream
    // picks up the user, but we can rely on the AuthProvider's internal
    // _isLoading state, which is watched by the build function.

    try {
      // The AuthProvider's internal loading state will be set to true before the async call
      await authActions.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Success: AuthWrapper handles navigation to BottomNav or EmailVerificationScreen
    } catch (e) {
      if (!mounted) return;
      // Extract the message from the thrown exception (which is often a String or FirebaseAuthException message)
      final message = e is Exception
          ? e.toString().replaceAll('Exception: ', '')
          : 'Login failed: check credentials.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // --- REQUIRED FUNCTIONALITY: Password Reset Dialog ---
  void _showPasswordResetDialog() {
    final resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: resetEmailController,
            decoration: const InputDecoration(
              labelText: 'Enter your email',
              labelStyle: TextStyle(color: Colors.black),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Send Link',
                style: TextStyle(color: Color.fromARGB(255, 1, 6, 37)),
              ),
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isEmpty) return;

                try {
                  await Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).sendPasswordResetEmail(email);
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password reset link sent! Check your email.',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    // We use the AuthProvider's dedicated loading state for the button
    final isLoading = authProvider.isLoading;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 6, 37),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Assuming BookIcon is defined in 'book_icon.dart'
                  const BookIcon(size: 100),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email field
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    controller: _emailController,
                    decoration: _inputDecoration('Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value != null &&
                            value.contains('@') &&
                            value.contains('.')
                        ? null
                        : 'Enter a valid email',
                  ),
                  const SizedBox(height: 20),

                  // Password field
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    controller: _passwordController,
                    decoration: _inputDecoration('Password'
                    , suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) => value != null && value.length >= 6
                        ? null
                        : 'Min 6 characters required',
                  ),
                  const SizedBox(height: 30),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          214,
                          224,
                          31,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading ? null : () => _login(context),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- REQUIRED: Forgot Password Link ---
                  TextButton(
                    onPressed: isLoading ? null : _showPasswordResetDialog,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Go to Signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                // Use pushReplacementNamed if you want to replace the login screen
                                // but pushNamed is often better for a flexible navigation flow.
                                Navigator.pushNamed(context, '/signup');
                              },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color.fromARGB(255, 210, 231, 23),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color.fromARGB(255, 13, 19, 60),
      // Use focusedBorder and enabledBorder that match the style
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.yellow, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color.fromARGB(255, 13, 19, 60)),
        borderRadius: BorderRadius.circular(12),
      ),
      // Set the color for the validator text to ensure it's visible on dark background
      errorStyle: const TextStyle(color: Colors.redAccent),
      suffixIcon: suffixIcon,
    );
  }
}
