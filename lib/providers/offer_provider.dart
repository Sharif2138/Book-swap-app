import 'package:flutter/material.dart';
import '../models/offer_model.dart';
import '../services/firestore_service.dart';
// import 'auth_provider.dart';
// import 'package:provider/provider.dart';

class OfferProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();
  List<Offer> offers = [];
  bool isLoading = true;

  // Caller must call loadForUser(uid)
  void loadForUser(String uid) {
    _fs.offersForUser(uid).listen((list) {
      offers = list;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> acceptOffer(String offerId, String bookId) async {
    await _fs.updateOfferStatus(offerId, 'Accepted');
    await _fs.setBookSwapState(bookId, 'Accepted');
  }

  Future<void> rejectOffer(String offerId, String bookId) async {
    await _fs.updateOfferStatus(offerId, 'Rejected');
    await _fs.setBookSwapState(bookId, 'Available');
  }
}
