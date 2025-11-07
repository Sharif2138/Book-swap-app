// import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Sign Up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // 1. Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 2. Send email verification
        await firebaseUser.sendEmailVerification();

        // 3. Create initial profile data
        final newUser = UserModel(
          id: firebaseUser.uid,
          email: email,
          name: name,
          isEmailVerified: false, // Starts as false
        );

        // 4. Save profile to Firestore
        await _db
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());

        return newUser;
      }
      return null;
    } on FirebaseAuthException {
      // Handle Firebase errors (e.g., email already in use, weak password)
      rethrow;
    }
  }

  // 2. Sign In
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Fetch the user's full profile from Firestore
        final doc = await _db.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          // Check verification status from the live Firebase User object
          await firebaseUser.reload(); // Ensure we have the latest status
          final isVerified = _auth.currentUser?.emailVerified ?? false;

          // Return the AppUser model combined with the latest verification status
          final userData = doc.data()!;
          return UserModel.fromMap({
            ...userData,
            'isEmailVerified': isVerified, // Overwrite with live status
          });
        }
      }
      return null;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // 3. Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 4. Real-time Authentication State Stream (Crucial for Provider)
  Stream<UserModel?> get userChanges {
    // This stream listens to Firebase's auth state (logged in/out)
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) {
        return null; // User is logged out
      } else {
        // User is logged in, fetch their profile and latest verification status
        final doc = await _db.collection('users').doc(user.uid).get();
        if (doc.exists) {
          await user.reload();
          final isVerified = _auth.currentUser?.emailVerified ?? false;
          final userData = doc.data()!;
          return UserModel.fromMap({
            ...userData,
            'isEmailVerified': isVerified,
          });
        }
        return null;
      }
    });
  }
}
