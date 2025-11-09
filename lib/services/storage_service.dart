import 'dart:io';
// import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// [image] can be File (mobile) or Uint8List (web).
  Future<String> uploadBookImage(dynamic imageData, String id) async {
    final ref = _storage.ref().child('books/$id.jpg');

    UploadTask uploadTask;
    if (kIsWeb) {
      if (imageData is Uint8List == false) {
        throw Exception('On web, imageData must be Uint8List');
      }
      uploadTask = ref.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );
    } else {
      if (imageData is File == false) {
        throw Exception('On mobile, imageData must be File');
      }
      uploadTask = ref.putFile(imageData);
    }

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
