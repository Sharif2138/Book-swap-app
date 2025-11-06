import 'package:book_swap_app/ui/screens/onboarding/signup_screen.dart';
import 'package:flutter/material.dart';
// import 'package:book_swap_app/ui/screens/home_page.dart';
// // import 'package:google_fonts/google_fonts.dart';
// import 'package:book_swap_app/ui/screens/signup_screen.dart';

void main() {
  runApp(BookSwap());
}

class BookSwap extends StatelessWidget {
  const BookSwap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Swap App',
      home: SignupScreen());
  }
}
