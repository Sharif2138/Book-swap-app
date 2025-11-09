import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/offer_provider.dart';
import '../../models/book_model.dart';
import 'add_edit_book_screen.dart';

class BrowseListingsScreen extends StatelessWidget {
  const BrowseListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProv = Provider.of<BookProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);
    final offerProv = Provider.of<OfferProvider>(context);

    final books = bookProv.books;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 244, 246),
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: const Color.fromARGB(255, 1, 6, 37),
        title: const Text(
          'Browse Listings',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: bookProv.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 214, 224, 31),
              ),
            )
          : books.isEmpty
          ? const Center(
              child: Text(
                'No books available yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              color: const Color.fromARGB(255, 214, 224, 31),
              onRefresh: () async {
                bookProv.isLoading = true;
                await Future.delayed(const Duration(seconds: 1));
                bookProv.isLoading = false;
              },
              child: ListView.separated(
                itemCount: books.length,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                separatorBuilder: (ctx, i) => const Divider(
                  color: Colors.grey,
                  thickness: 0.4,
                  height: 25,
                ),
                itemBuilder: (ctx, i) {
                  final book = books[i];
                  final isOwner = authProv.user?.uid == book.ownerId;

                  final hasPendingOffer = offerProv.offers.any(
                    (o) =>
                        o.bookId == book.id &&
                        o.fromUserId == authProv.user?.uid &&
                        o.status == 'Pending',
                  );

                  return BookListingTile(
                    book: book,
                    isOwner: isOwner,
                    onSwap: (!isOwner && !hasPendingOffer)
                        ? () async {
                            if (authProv.user == null) return;
                            await bookProv.requestSwap(
                              bookId: book.id,
                              fromUserId: authProv.user!.uid,
                              toUserId: book.ownerId,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Swap request sent!'),
                              ),
                            );
                          }
                        : null,
                    swapButtonDisabled: hasPendingOffer,
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditBookScreen()),
        ),
        label: const Text('Post'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 193, 202, 17),
        foregroundColor: Colors.black,
      ),
    );
  }
}

class BookListingTile extends StatelessWidget {
  final Book book;
  final bool isOwner;
  final VoidCallback? onSwap;
  final bool swapButtonDisabled;

  const BookListingTile({
    super.key,
    required this.book,
    this.isOwner = false,
    this.onSwap,
    this.swapButtonDisabled = false,
  });

  Widget _buildBookImage() {
    if (book.imageBase64 != null && book.imageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(book.imageBase64!);
        return Image.memory(bytes, width: 100, height: 140, fit: BoxFit.cover);
      } catch (_) {}
    }
    return Container(
      width: 100,
      height: 140,
      color: Colors.blueGrey,
      child: const Icon(Icons.menu_book, color: Colors.white, size: 40),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBookImage(),
        const SizedBox(width: 15),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOwner)
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditBookScreen(book: book),
                              ),
                            );
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text(
                                  'Are you sure you want to delete this book?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await Provider.of<BookProvider>(
                                context,
                                listen: false,
                              ).deleteBook(book.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Book deleted successfully!'),
                                ),
                              );
                            }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  book.author,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[50],
                    borderRadius: BorderRadius.circular(4),
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
                const SizedBox(height: 8),
                if (!isOwner)
                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: swapButtonDisabled ? null : onSwap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: swapButtonDisabled
                            ? Colors.grey.shade400
                            : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        swapButtonDisabled ? 'Requested' : 'Swap',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  const Text(
                    'Your Listing',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
