import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  User? user;
  Map<String, dynamic>? userData; // Stores name, email, etc.
  bool isInitializing = true;

  AuthProvider() {
    _service.authStateChanges().listen((u) async {
      user = u;
      if (user != null) {
        userData = await _service.getUserInfo(user!.uid);
      } else {
        userData = null;
      }
      isInitializing = false;
      notifyListeners();
    });
  }

  bool get isLoading => false;

  Future<void> signUp(String name, String email, String password) async {
    user = await _service.signUp(name, email, password);
    if (user != null) {
      userData = await _service.getUserInfo(user!.uid);
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    user = await _service.signIn(email, password);
    if (user != null) {
      userData = await _service.getUserInfo(user!.uid);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    user = null;
    userData = null;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    // implement if needed
  }

  String get name => userData?['name'] ?? '';
  String get email => userData?['email'] ?? '';
}
