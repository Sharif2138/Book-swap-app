import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for User type

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;
  // **NEW: Required for assignment's email verification requirement**
  final bool isEmailVerified;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isEmailVerified, // Added to constructor
    this.imageUrl,
  });

  // --- Factory Methods ---

  /// Creates a UserModel from a Firebase Auth User object.
  /// This is used immediately after sign-in/sign-up.
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      name: user.displayName ?? 'New User', // Use display name or default
      email: user.email ?? '',
      imageUrl: user.photoURL,
      isEmailVerified: user.emailVerified, // Get verification status
    );
  }

  /// Creates a UserModel from Firestore document data.
  factory UserModel.fromFirestore(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] as String? ?? 'Unknown',
      email: map['email'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      // **NEW: Must retrieve verification status from Firestore if stored there**
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
    );
  }

  // --- Conversion Methods ---

  /// Converts the UserModel instance to a map suitable for Firestore.
  Map<String, dynamic> toFirestore() {
    // Note: We often store 'isEmailVerified' in Firestore for easy access,
    // though the authoritative source is always Firebase Auth.
    return {
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'isEmailVerified': isEmailVerified, // Included for storage
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Converts the UserModel instance to a map suitable for initial Firestore creation.
  Map<String, dynamic> toCreationFirestore() {
    final map = toFirestore();
    map['createdAt'] = FieldValue.serverTimestamp();
    return map;
  }

  // --- Utility Methods ---

  /// Allows updating user fields locally.
  UserModel copyWith({
    String? name,
    String? email,
    String? imageUrl,
    bool? isEmailVerified, // Added to copyWith
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, isEmailVerified: $isEmailVerified)';
  }
}
