import 'dart:convert';
// import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../screens/add_edit_book_screen.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final bool isOwner;
  const BookCard({super.key, required this.book, this.isOwner = false});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final bp = Provider.of<BookProvider>(context, listen: false);

    Widget imageWidget() {
      if (book.imageBase64 != null && book.imageBase64!.isNotEmpty) {
        final bytes = base64Decode(book.imageBase64!);
        return Image.memory(bytes, width: 56, height: 56, fit: BoxFit.cover);
      }
      return const Icon(Icons.book, size: 48);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: ListTile(
        leading: imageWidget(),
        title: Text(book.title),
        subtitle: Text(
          '${book.author} · ${book.condition}\nState: ${book.swapState}',
        ),
        isThreeLine: true,
        trailing: isOwner
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditBookScreen(book: book),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => bp.deleteBook(book.id),
                  ),
                ],
              )
            : book.swapState == 'Available'
            ? ElevatedButton(
                onPressed: () async {
                  final fromUid = auth.user!.uid;
                  await bp.requestSwap(bookId: book.id, fromUserId: fromUid, toUserId: book.ownerId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Swap requested')),
                  );
                },
                child: const Text('Swap'),
              )
            : Text(book.swapState, style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}
