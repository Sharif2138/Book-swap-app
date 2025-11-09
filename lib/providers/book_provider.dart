import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/firestore_service.dart';
// import '../models/offer_model.dart';

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
    await _fs.addBook(b);
  }

  Future<void> updateBook(Book b) async {
    await _fs.updateBook(b);
  }

  Future<void> deleteBook(String id) async {
    await _fs.deleteBook(id);
  }

  /// Request a swap for a book
  /// Prevents duplicate pending offers from the same user
  Future<void> requestSwap({
    required String bookId,
    required String fromUserId, // requester
    required String toUserId, // owner
  }) async {
    // 1. Check if a pending offer already exists for this user and book
    final existingOffers = await _fs.getPendingOffersForBookByUser(
      bookId,
      fromUserId,
    );

    if (existingOffers.isNotEmpty) {
      // Avoid creating duplicate pending offer
      debugPrint("A pending offer already exists for this book and user.");
      return;
    }

    // 2. Create a new offer
    await _fs.createOffer(bookId, fromUserId, toUserId);

    // 3. Set book's swapState to Pending
    await _fs.setBookSwapState(bookId, 'Pending');
  }
}
