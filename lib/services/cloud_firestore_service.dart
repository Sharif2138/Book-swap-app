import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_model.dart'; // Assuming this path is correct

class CloudFirestoreService {
  // Instance of the database
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Name of the top-level collection for users
  final String _userCollection = 'Users';

  // --- 1. Fetch ALL Users (Corrected) ---
  /// Fetches all documents from the 'Users' collection and maps them to a List of UserModel.
  Future<List<UserModel>> getAllUsers() async {
    try {
      // 🎯 Correctly targets the entire 'Users' collection and fetches all documents
      final QuerySnapshot snapshot = await _db
          .collection(_userCollection)
          .get();

      // Maps the list of DocumentSnapshots to a list of UserModel objects
      return snapshot.docs.map((doc) {
        // We cast the data to a Map to ensure type safety before passing to the factory constructor
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromFirestore(
          data,
          doc.id,
        ); // Assuming fromFirestore takes data and ID
      }).toList();
    } catch (e) {
      // Log error for debugging
      if (kDebugMode) {
        print("Error getting all users: $e");
      }
      // Return an empty list on failure
      return [];
    }
  }

  // --- 2. Fetch Single User ---
  /// Fetches a single user document by their ID.
  Future<UserModel?> getUser({required String userId}) async {
    try {
      // 🎯 Targets a specific document within the 'Users' collection
      final DocumentSnapshot doc = await _db
          .collection(_userCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromFirestore(data, doc.id);
      } else {
        if (kDebugMode) {
          print("User document with ID $userId not found.");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting user $userId: $e");
      }
      return null;
    }
  }

  // NOTE: I removed the unused 'package:flutter/material.dart' import as it's not needed here.
}
