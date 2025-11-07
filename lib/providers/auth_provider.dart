import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Private State
  UserModel? _user;
  bool _isLoading = true;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated =>
      _user?.isEmailVerified ?? false; // Enforce verification

  // Constructor: Subscribes to the AuthService stream immediately
  AuthProvider() {
    // We use the stream from AuthService to manage the global authentication state
    _authService.userChanges.listen((appUser) {
      _user = appUser;
      _isLoading = false;
      notifyListeners(); // Tell all UI listeners the auth state has changed
    });
  }

  // Methods for UI to call
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authService.signIn(email: email, password: password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null; // Update local state immediately
    notifyListeners();
  }
}
