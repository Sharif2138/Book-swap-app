import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/firestore_service.dart';

class BookProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();
  List<Book> books = [];
  bool isLoading = true;

  BookProvider() {
    _fs.booksStream().listen((list) {
      books = list;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addBook(Book b) async {
    // Ensure imageBase64 is included
    await _fs.addBook(b);
  }

  Future<void> updateBook(Book b) async {
    await _fs.updateBook(b);
  }

  Future<void> deleteBook(String id) async {
    await _fs.deleteBook(id);
  }

  /// Creates an offer and sets book swapState to Pending
  Future<void> requestSwap(
    String bookId,
    String fromUserId,
    String toUserId,
  ) async {
    // final offer = await _fs.createOffer(bookId, fromUserId, toUserId);
    await _fs.setBookSwapState(bookId, 'Pending');
    // Stream updates will refresh UI automatically
  }
}
