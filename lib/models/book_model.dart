import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';

class Book {
  final String id;
  final String title;
  final String author;
  final String condition;
  final String? imageBase64; // Base64 image stored in Firestore
  final String ownerId;
  final String swapState; // Available, Pending, Accepted, Rejected

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    this.imageBase64,
    required this.ownerId,
    this.swapState = 'Available',
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      condition: data['condition'] ?? 'Good',
      imageBase64: data['imageBase64'],
      ownerId: data['ownerId'] ?? '',
      swapState: data['swapState'] ?? 'Available',
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'author': author,
    'condition': condition,
    if (imageBase64 != null) 'imageBase64': imageBase64,
    'ownerId': ownerId,
    'swapState': swapState,
    'createdAt': FieldValue.serverTimestamp(),
  };

  /// Helper to get image as Uint8List for Image.memory
  Uint8List? get imageBytes =>
      imageBase64 != null ? base64Decode(imageBase64!) : null;
}
