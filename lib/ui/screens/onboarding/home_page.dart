import 'package:flutter/material.dart';
import 'package:book_swap_app/ui/widgets/book_icon.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 6, 37),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 30.0),
              const BookIcon(size: 130.0,),
              SizedBox(height: 10.0),
              const Text(
                "BookSwap",
                style: TextStyle(
                  fontSize: 60.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10.0),
              const Text(
                "Swap Your Books",
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Text(
                "With Other Students",
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 50.0),
              const Text(
                "Sign in to get started",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 50.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
