import 'package:flutter/material.dart';
import 'package:book_swap_app/ui/widgets/book_icon.dart';
import 'login_screen.dart'; 

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers to collect text
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // A simple form key
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
                    'Create Your Account',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- Name field ---
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Full Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 20),

                  // --- Email field ---
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration('Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.contains('@') ? null : 'Enter a valid email',
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

                  // --- Signup Button ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 173, 207, 19),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Handle signup logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Account Created!')),
                          );
                        }
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- Go to Login ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Color.fromARGB(255, 181, 210, 15)),
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

  // Custom input field style
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
