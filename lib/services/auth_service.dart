import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

// AuthService must extend ChangeNotifier to work with Provider
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Internal cache of the current user, updated by the stream listener
  UserModel? _currentUser;

  // --- Core State Stream for AuthWrapper ---

  // Expose the core Firebase User stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Method to get the full UserModel (from Auth and Firestore)
  // Used by AuthWrapper or any screen that needs user profile data.
  Future<UserModel?> getCurrentUserModel(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      notifyListeners();
      return null;
    }

    // 1. Convert Firebase User to initial UserModel
    UserModel userModel = UserModel.fromFirebaseUser(firebaseUser);

    // 2. Fetch additional data from Firestore
    try {
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        // Merge data from Firestore (name, imageUrl) and Auth (id, email, isEmailVerified)
        userModel = UserModel.fromFirestore(
          doc.data()!,
          firebaseUser.uid,
        ).copyWith(isEmailVerified: firebaseUser.emailVerified);
      } else {
        // If Firestore document doesn't exist (e.g., failed to write on signup),
        // create a new entry with basic auth data and the isEmailVerified status.
        await _db
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userModel.toCreationFirestore());
      }
    } catch (e) {
      debugPrint('Error fetching user data from Firestore: $e');
      // Continue with the minimal UserModel from Firebase Auth on failure
    }

    _currentUser = userModel;
    // We don't call notifyListeners here; the StreamProvider in main.dart handles updates.
    return userModel;
  }

  // Public getter for the latest cached user model
  UserModel? get currentUser => _currentUser;

  // --- Sign Up ---
  Future<UserModel?> signUp(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;

      // Update display name immediately (optional but good practice)
      await firebaseUser.updateDisplayName(name);

      // Create initial UserModel with verification status (which will be false)
      UserModel newUser = UserModel.fromFirebaseUser(
        firebaseUser,
      ).copyWith(name: name);

      // 1. Save user profile to Firestore
      await _db
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newUser.toCreationFirestore());

      // 2. Send email verification (Critical requirement)
      await sendEmailVerification(firebaseUser);

      // We don't set _currentUser here; the authStateChanges stream handles this.
      return newUser;
    } on FirebaseAuthException catch (e) {
      // Throw the message for the UI to display
      throw e.message ?? 'Signup failed';
    }
  }

  // --- Sign In ---
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Fetches and updates the internal cache
        return await getCurrentUserModel(firebaseUser);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Sign-in failed';
    }
  }

  // --- Sign Out ---
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners(); // Notify listeners that the user state has changed to null
  }

  // --- Email Verification and Password Reset Methods ---

  // Send Email Verification (Public method for UI)
  Future<void> sendEmailVerification([User? user]) async {
    final targetUser = user ?? _auth.currentUser;
    if (targetUser != null) {
      try {
        await targetUser.sendEmailVerification();
      } on FirebaseAuthException catch (e) {
        throw e.message ?? 'Failed to send verification email.';
      }
    }
  }

  // Reload User Status (for checking if verification succeeded)
  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      // Force an update to the user model and notify listeners
      await getCurrentUserModel(_auth.currentUser);
      notifyListeners();
    }
  }

  // Password Reset (Public method for UI)
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Failed to send password reset email.';
    }
  }
}
