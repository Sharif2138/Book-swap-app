import 'package:flutter/material.dart';
import 'package:book_swap_app/ui/widgets/book_icon.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 6, 37),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const BookIcon(size: 100),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- Email field ---
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration('Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.contains('@') ? null : 'Enter valid email',
                  ),
                  const SizedBox(height: 20),

                  // --- Password field ---
                  TextFormField(
                    controller: _passwordController,
                    decoration: _inputDecoration('Password'),
                    obscureText: true,
                    validator: (value) =>
                        value!.length < 6 ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 30),

                  // --- Login Button ---
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Logged in!')),
                          );
                        }
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- Go to Signup ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(color: Color.fromARGB(255, 210, 231, 23)),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color.fromARGB(255, 13, 19, 60),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.deepPurpleAccent),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
