import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/offer_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/offer_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SwapOffersScreen extends StatefulWidget {
  const SwapOffersScreen({super.key});

  @override
  State<SwapOffersScreen> createState() => _SwapOffersScreenState();
}

class _SwapOffersScreenState extends State<SwapOffersScreen> {
  bool _loaded = false;
  final FirestoreService _fs = FirestoreService();
  final Map<String, String> _userNames = {}; // cache

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        Provider.of<OfferProvider>(
          context,
          listen: false,
        ).loadForUser(auth.user!.uid);
      }
      _loaded = true;
    }
  }

  Widget _buildBookImage(String? base64) {
    if (base64 != null && base64.isNotEmpty) {
      try {
        final bytes = base64Decode(base64);
        return Image.memory(bytes, width: 80, height: 120, fit: BoxFit.cover);
      } catch (_) {}
    }
    return Container(
      width: 80,
      height: 120,
      color: Colors.blueGrey,
      child: const Icon(Icons.menu_book, color: Colors.white),
    );
  }

  /// Get user name from cache or Firestore
  Future<String> _getUserName(String uid) async {
    if (_userNames.containsKey(uid)) return _userNames[uid]!;
    try {
      final data = await _fs.getUserInfo(uid);
      final name = data?['name'] ?? 'Unknown User';
      _userNames[uid] = name;
      return name;
    } catch (_) {
      return 'Unknown User';
    }
  }

  @override
  Widget build(BuildContext context) {
    final offerProv = Provider.of<OfferProvider>(context);
    final bookProv = Provider.of<BookProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final userBooks = bookProv.books
        .where((b) => b.ownerId == auth.user?.uid)
        .toList();

    if (offerProv.isLoading && userBooks.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings & Offers'),
        toolbarHeight: 90,
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 1, 6, 37),
        foregroundColor: Colors.white,
      ),
      body: userBooks.isEmpty
          ? const Center(child: Text('No books listed'))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              itemCount: userBooks.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 25, color: Colors.grey),
              itemBuilder: (_, i) {
                final book = userBooks[i];
                final bookOffers = offerProv.offers
                    .where((o) => o.bookId == book.id)
                    .toList();
                final hasPendingOffer = bookOffers.any(
                  (o) => o.status == 'Pending',
                );

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hasPendingOffer
                        ? Colors.yellow[50]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBookImage(book.imageBase64),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  book.author,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple[50],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    book.condition,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepPurple[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Offers
                      if (bookOffers.isEmpty)
                        const Text(
                          'No offers yet',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        Column(
                          children: bookOffers.map((offer) {
                            final isPending = offer.status == 'Pending';
                            final requesterName =
                                _userNames[offer.fromUserId] ?? 'Loading...';

                            return OfferTile(
                              offer: offer,
                              requesterName: requesterName,
                              isPending: isPending,
                              onAccept: () async {
                                await offerProv.acceptOffer(
                                  offer.id,
                                  offer.bookId,
                                );
                              },
                              onReject: () async {
                                await offerProv.rejectOffer(
                                  offer.id,
                                  offer.bookId,
                                );
                              },
                              getName: () async {
                                // fetch in background if not cached
                                if (!_userNames.containsKey(offer.fromUserId)) {
                                  // ignore: unused_local_variable
                                  final name = await _getUserName(
                                    offer.fromUserId,
                                  );
                                  setState(
                                    () {},
                                  ); // refresh to show fetched name
                                }
                              },
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class OfferTile extends StatefulWidget {
  final Offer offer;
  final String requesterName;
  final bool isPending;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final Future<void> Function() getName;

  const OfferTile({
    super.key,
    required this.offer,
    required this.requesterName,
    required this.isPending,
    required this.onAccept,
    required this.onReject,
    required this.getName,
  });

  @override
  State<OfferTile> createState() => _OfferTileState();
}

class _OfferTileState extends State<OfferTile> {
  late String _name;

  @override
  void initState() {
    super.initState();
    _name = widget.requesterName;
    widget.getName(); // fetch in background if needed
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Swap requested by $_name',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Row(
            children: [
              if (widget.isPending) ...[
                TextButton(
                  onPressed: widget.onAccept,
                  child: const Text(
                    'Accept',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.onReject,
                  child: const Text(
                    'Reject',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.offer.status == 'Accepted'
                        ? Colors.green[50]
                        : Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.offer.status,
                    style: TextStyle(
                      color: widget.offer.status == 'Accepted'
                          ? Colors.green[800]
                          : Colors.red[800],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// FirestoreService extension
extension FirestoreServiceUserInfo on FirestoreService {
  Future<Map<String, dynamic>?> getUserInfo(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }
}
