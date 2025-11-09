import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../models/offer_model.dart';

class FirestoreService {
  final booksCol = FirebaseFirestore.instance.collection('books');
  final offersCol = FirebaseFirestore.instance.collection('offers');

  // Books
  Stream<List<Book>> booksStream() {
    return booksCol
        .orderBy('title')
        .snapshots()
        .map((s) => s.docs.map((d) => Book.fromFirestore(d)).toList());
  }

  Future<void> addBook(Book b) => booksCol.add(b.toMap());
  Future<void> updateBook(Book b) => booksCol.doc(b.id).update(b.toMap());
  Future<void> deleteBook(String id) => booksCol.doc(id).delete();

  // Offers
  Stream<List<Offer>> offersForUser(String uid) {
    // offers where fromUserId==uid OR toUserId==uid
    return offersCol
        .where(
          'participants',
          arrayContains: uid,
        ) // we'll store participants to ease queries
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Offer.fromFirestore(d)).toList());
  }

  Future<Offer> createOffer(
    String bookId,
    String fromUserId,
    String toUserId,
  ) async {
    final data = {
      'bookId': bookId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
      'participants': [fromUserId, toUserId],
    };
    final docRef = await offersCol.add(data);
    final snap = await docRef.get();
    return Offer.fromFirestore(snap);
  }

  Future<void> updateOfferStatus(String offerId, String status) =>
      offersCol.doc(offerId).update({'status': status});

  // Update corresponding book swapState when offer status changes
  Future<void> setBookSwapState(String bookId, String swapState) =>
      booksCol.doc(bookId).update({'swapState': swapState});
}
