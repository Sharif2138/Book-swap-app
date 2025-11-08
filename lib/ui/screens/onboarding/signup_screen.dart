// ignore_for_file: use_build_context_synchronously

import 'package:book_swap_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:book_swap_app/ui/widgets/book_icon.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true; 

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
        // Using the yellow accent color for consistency with LoginScreen
        borderSide: const BorderSide(color: Color.fromARGB(255, 214, 224, 31), width: 2),
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;
     // initial state: password hidden

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
                  const BookIcon(size: 100),
                  const SizedBox(height: 20),
                  const Text(
                    'Create Your Account',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Name field
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    controller: _nameController,
                    decoration: _inputDecoration('Full Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 20),

                  // Email field
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    controller: _emailController,
                    decoration: _inputDecoration('Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value != null &&
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
                    decoration: _inputDecoration(
                      'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
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

                  // Signup button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 214, 224, 31),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              FocusScope.of(context).unfocus();

                              if (!_formKey.currentState!.validate()) return;

                              final authActions = context.read<AuthProvider>();

                              try {
                                await authActions.signUp(
                                  _nameController.text.trim(),
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                                // No manual navigation needed — AuthWrapper handles redirection
                              } catch (e) {
                                final message = e is Exception
                                    ? e.toString().replaceAll('Exception: ', '')
                                    : 'Sign up failed';
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)),
                                  );
                                }
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Go to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: isLoading ? null : () {
                          // Use pop here as the Login screen should already be in the stack,
                          // or pushReplacementNamed if using the full routing setup.
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Login',
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
}


