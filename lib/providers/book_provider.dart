import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/firestore_service.dart';

class BookProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();
  List<Book> books = [];
  bool isLoading = true;

  BookProvider() {
    _initBooks();
  }

  void _initBooks() {
    // Listen to real-time updates from Firestore
    _fs.booksStream().listen((list) {
      books = list;
      isLoading = false;
      notifyListeners();
    });
  }

  /// Add a new book
  Future<void> addBook(Book b) async {
    try {
      await _fs.addBook(b);
      // Books stream will automatically update `books`
    } catch (e) {
      throw Exception('Failed to add book: $e');
    }
  }

  /// Update an existing book
  Future<void> updateBook(Book b) async {
    try {
      await _fs.updateBook(b);
      // Books stream will automatically update `books`
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  /// Delete a book by ID
  Future<void> deleteBook(String id) async {
    try {
      await _fs.deleteBook(id);
      // Books stream will automatically update `books`
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  /// Request a swap for a book
  /// Prevents duplicate pending offers
  Future<void> requestSwap({
    required String bookId,
    required String fromUserId, // requester
    required String toUserId, // owner
  }) async {
    try {
      // 1. Check if a pending offer already exists for this user and book
      final existingOffers = await _fs.getPendingOffersForBookByUser(
        bookId,
        fromUserId,
      );

      if (existingOffers.isNotEmpty) {
        // Do not create another offer
        return;
      }

      // 2. Create a new offer
      await _fs.createOffer(bookId, fromUserId, toUserId);

      // 3. Set book's swapState to Pending
      await _fs.setBookSwapState(bookId, 'Pending');

      notifyListeners(); // UI reacts to the swap request
    } catch (e) {
      throw Exception('Failed to request swap: $e');
    }
  }
}
