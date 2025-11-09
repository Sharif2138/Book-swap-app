import 'package:cloud_firestore/cloud_firestore.dart';

class Offer {
  final String id;
  final String bookId;
  final String fromUserId; // requester
  final String toUserId; // owner
  final String status; // Pending, Accepted, Rejected
  final Timestamp createdAt;

  Offer({
    required this.id,
    required this.bookId,
    required this.fromUserId,
    required this.toUserId,
    this.status = 'Pending',
    Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now();

  factory Offer.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Offer(
      id: doc.id,
      bookId: d['bookId'] ?? '',
      fromUserId: d['fromUserId'] ?? '',
      toUserId: d['toUserId'] ?? '',
      status: d['status'] ?? 'Pending',
      createdAt: d['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'bookId': bookId,
    'fromUserId': fromUserId,
    'toUserId': toUserId,
    'status': status,
    'createdAt': createdAt,
  };
}
