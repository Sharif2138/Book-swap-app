import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // Signup with name, email, password and save to Firestore
  Future<User?> signUp(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user!;

    // 1️⃣ Update the displayName
    await user.updateDisplayName(name);

    // 2️⃣ Reload the user so that displayName is available immediately
    await user.reload();

    // 3️⃣ Save to Firestore
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 4️⃣ Send verification email
    await user.sendEmailVerification();

    // 5️⃣ Return the reloaded user
    return _auth.currentUser;
  }

  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;
    if (user != null && !user.emailVerified) {
      await _auth.signOut();
      throw Exception('Please verify your email before logging in.');
    }

    return user;
  }

  Future<void> signOut() async => await _auth.signOut();

  // Fetch user info from Firestore
  Future<Map<String, dynamic>?> getUserInfo(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
}
