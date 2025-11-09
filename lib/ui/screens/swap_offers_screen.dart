import 'dart:convert';
// import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/offer_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../models/offer_model.dart';

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

  Widget _buildBookImage(String? base64) {
    if (base64 != null && base64.isNotEmpty) {
      try {
        final bytes = base64Decode(base64);
        return Image.memory(bytes, width: 60, height: 80, fit: BoxFit.cover);
      } catch (_) {}
    }
    // fallback if no image or decode fails
    return Container(
      width: 60,
      height: 80,
      color: Colors.grey[300],
      child: const Icon(Icons.menu_book, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offerProv = Provider.of<OfferProvider>(context);
    final bookProv = Provider.of<BookProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

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
          : userBooks.isEmpty
          ? const Center(child: Text('No books listed'))
          : ListView.builder(
              itemCount: userBooks.length,
              itemBuilder: (ctx, i) {
                final book = userBooks[i];
                final pendingOffer = offerProv.offers.firstWhere(
                  (o) =>
                      o.bookId == book.id &&
                      o.status == 'Pending' &&
                      o.toUserId == auth.user!.uid,
                  orElse: () => Offer(
                    id: '',
                    bookId: '',
                    fromUserId: '',
                    toUserId: '',
                    status: '',
                  ),
                );

                final hasPendingOffer = pendingOffer.id.isNotEmpty;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildBookImage(book.imageBase64),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.author,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple[50],
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      book.condition,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.deepPurple[700],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Owner: ${auth.user?.email ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasPendingOffer)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                    onPressed: () async =>
                                        await Provider.of<OfferProvider>(
                                          context,
                                          listen: false,
                                        ).acceptOffer(
                                          pendingOffer.id,
                                          pendingOffer.bookId,
                                        ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async =>
                                        await Provider.of<OfferProvider>(
                                          context,
                                          listen: false,
                                        ).rejectOffer(
                                          pendingOffer.id,
                                          pendingOffer.bookId,
                                        ),
                                  ),
                                ],
                              )
                            else
                              Icon(
                                Icons.hourglass_empty,
                                color: Colors.grey[400],
                                size: 32,
                              ),
                            const SizedBox(height: 4),
                            Text(
                              hasPendingOffer ? 'Pending Offer' : 'No Offers',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: hasPendingOffer
                                    ? Colors.green
                                    : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
