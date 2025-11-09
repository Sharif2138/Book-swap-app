import 'package:flutter/material.dart';
import '../models/offer_model.dart';
import '../services/firestore_service.dart';

class OfferProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();
  List<Offer> offers = [];
  bool isLoading = true;

  /// Load all offers related to a user (as owner or requester)
  void loadForUser(String uid) {
    _fs.offersForUser(uid).listen((list) {
      offers = list;
      isLoading = false;
      notifyListeners();
    });
  }

  /// Accept an offer: update offer status and book swapState
  Future<void> acceptOffer(String offerId, String bookId) async {
    // Update offer to Accepted
    await _fs.updateOfferStatus(offerId, 'Accepted');

    // Update book's swapState to Accepted
    await _fs.setBookSwapState(bookId, 'Accepted');

    // Reject all other pending offers for this book
    final pendingOffers = offers
        .where(
          (o) => o.bookId == bookId && o.status == 'Pending' && o.id != offerId,
        )
        .toList();

    for (var o in pendingOffers) {
      await _fs.updateOfferStatus(o.id, 'Rejected');
    }

    notifyListeners();
  }

  /// Reject an offer: update offer status and set book available if no other pending offers
  Future<void> rejectOffer(String offerId, String bookId) async {
    await _fs.updateOfferStatus(offerId, 'Rejected');

    final otherPending = offers
        .where((o) => o.bookId == bookId && o.status == 'Pending')
        .isNotEmpty;

    if (!otherPending) {
      await _fs.setBookSwapState(bookId, 'Available');
    }

    notifyListeners();
  }

  /// Delete a pending offer initiated by the user
  Future<void> deleteOffer(String offerId) async {
    // Find the offer before deleting
    final index = offers.indexWhere((o) => o.id == offerId);
    if (index == -1) return;
    final offer = offers[index];

    final bookId = offer.bookId;

    // Delete the offer
    await _fs.deleteOffer(offerId);

    // If no other pending offers for the book, set swapState to Available
    final otherPending = offers
        .where(
          (o) => o.bookId == bookId && o.status == 'Pending' && o.id != offerId,
        )
        .isNotEmpty;

    if (!otherPending) {
      await _fs.setBookSwapState(bookId, 'Available');
    }

    notifyListeners();
  }
}
