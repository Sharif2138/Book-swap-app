import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Private State ---
  UserModel? _user;
  bool _isLoading = true;

  // --- Getters ---
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.isEmailVerified ?? false;

  // --- Constructor: listen to auth changes ---
  AuthProvider() {
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        _user = await _getCurrentUserModel(firebaseUser);
      } else {
        _user = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  // Helper method to fetch and merge user data from Auth and Firestore
  Future<UserModel?> _getCurrentUserModel(User firebaseUser) async {
    // ... (This logic remains the same) ...
    UserModel userModel = UserModel.fromFirebaseUser(firebaseUser);

    try {
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        userModel = UserModel.fromFirestore(
          doc.data()!,
          firebaseUser.uid,
        ).copyWith(isEmailVerified: firebaseUser.emailVerified);
      } else {
        await _db
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userModel.toCreationFirestore());
      }
    } catch (e) {
      debugPrint('Error fetching user data from Firestore: $e');
    }
    return userModel;
  }

  // --- Sign Up (FIXED) ---
  Future<void> signUp(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners(); // Show loading state

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user!;
      await firebaseUser.updateDisplayName(name);

      // Create initial UserModel with verification status (false)
      UserModel newUser = UserModel.fromFirebaseUser(
        firebaseUser,
      ).copyWith(name: name);

      // Save user profile to Firestore
      await _db
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newUser.toCreationFirestore());

      // Send email verification immediately
      await sendEmailVerification();

      // CRITICAL FIX: Manually update state to force AuthWrapper navigation
      _user = await _getCurrentUserModel(firebaseUser);
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      // Revert loading state on error
      _isLoading = false;
      notifyListeners();
      throw e.message ?? 'Signup failed';
    }
  }

  // --- Sign In (FIXED) ---
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners(); // Show loading state

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // CRITICAL FIX: Manually update state to force AuthWrapper navigation
      _user = await _getCurrentUserModel(userCredential.user!);
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      // Revert loading state on error
      _isLoading = false;
      notifyListeners();
      throw e.message ?? 'Sign-in failed';
    }
  }

  // --- Sign Out ---
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  // --- Email Verification and Password Reset Methods ---

  // 1. Send Email Verification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await user.sendEmailVerification();
      } on FirebaseAuthException catch (e) {
        throw e.message ?? 'Failed to send verification email.';
      }
    }
  }

  // 2. Reload User Status (for checking if verification succeeded)
  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      _user = await _getCurrentUserModel(_auth.currentUser!);
      notifyListeners();
    }
  }

  // 3. Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Failed to send password reset email.';
    }
  }
}
