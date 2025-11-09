import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/offer_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
// import 'add_edit_book_screen.dart';

class SwapOffersScreen extends StatefulWidget {
  const SwapOffersScreen({super.key});

  @override
  State<SwapOffersScreen> createState() => _SwapOffersScreenState();
}

class _SwapOffersScreenState extends State<SwapOffersScreen> {
  bool _loaded = false;

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


  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final offerProv = Provider.of<OfferProvider>(context);
    final bookProv = Provider.of<BookProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    // Get books the user owns or has made offers on
    final userBooks = bookProv.books
        .where((b) => b.ownerId == auth.user?.uid)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings & Offers'),
        toolbarHeight: 90,
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 1, 6, 37),
        foregroundColor: Colors.white,
      ),
      body: offerProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userBooks.isEmpty && offerProv.offers.isEmpty
          ? const Center(child: Text('No listings or offers'))
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              children: [
                // Owner's books
                ...userBooks.map((book) {
                  final bookOffers = offerProv.offers
                      .where((o) => o.bookId == book.id)
                      .toList();

                  return _BookOffersTile(
                    book: book,
                    offers: bookOffers,
                    isOwner: true,
                  );
                }),

                // Initiator's pending offers on other books
                const SizedBox(height: 16),
                const Text(
                  'Your Swap Requests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...offerProv.offers
                    .where(
                      (o) =>
                          o.fromUserId == auth.user?.uid &&
                          o.status == 'Pending',
                    )
                    .map((offer) {
                      final book = bookProv.books.firstWhere(
                        (b) => b.id == offer.bookId,
                      );
                      return _BookOffersTile(
                        book: book,
                        offers: [offer],
                        isOwner: false,
                      );
                    })
                    ,
              ],
            ),
    );
  }
}

class _BookOffersTile extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final book;
  final List offers;
  final bool isOwner;

  const _BookOffersTile({
    required this.book,
    required this.offers,
    this.isOwner = false,
  });

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

  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final offerProv = Provider.of<OfferProvider>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book info row
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
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
                    const SizedBox(height: 6),
                    Text(
                      book.createdAt != null
                          ? timeAgo(book.createdAt!.toDate())
                          : 'Unknown date',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Offers list
          if (offers.isEmpty)
            const Text('No offers', style: TextStyle(color: Colors.grey))
          else
            Column(
              children: offers.map((offer) {
                final isPending = offer.status == 'Pending';

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
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
                          isOwner
                              ? 'Swap requested by ${offer.fromUserName ?? offer.fromUserId}'
                              : 'Swap request for ${book.title}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isOwner && isPending) ...[
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              onPressed: () async => await offerProv
                                  .acceptOffer(offer.id, book.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () async => await offerProv
                                  .rejectOffer(offer.id, book.id),
                            ),
                          ] else if (!isOwner && isPending) ...[
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async =>
                                  await offerProv.deleteOffer(offer.id),
                            ),
                          ] else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: offer.status == 'Accepted'
                                    ? Colors.green[50]
                                    : Colors.red[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                offer.status,
                                style: TextStyle(
                                  color: offer.status == 'Accepted'
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
              }).toList(),
            ),
        ],
      ),
    );
  }
}
