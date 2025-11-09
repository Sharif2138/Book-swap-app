import 'dart:convert';
// import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import 'add_edit_book_screen.dart';

class BrowseListingsScreen extends StatelessWidget {
  const BrowseListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProv = Provider.of<BookProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);
    final books = bookProv.books;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 244, 246),
      appBar: AppBar(
        toolbarHeight: 90.0,
        backgroundColor: const Color.fromARGB(255, 1, 6, 37),
        title: const Text(
          'Browse Listings',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: bookProv.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 214, 224, 31),
              ),
            )
          : RefreshIndicator(
              color: const Color.fromARGB(255, 214, 224, 31),
              onRefresh: () async {},
              child: ListView.builder(
                itemCount: books.length,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                itemBuilder: (ctx, i) {
                  final b = books[i];
                  final isOwner =
                      authProv.user != null && b.ownerId == authProv.user!.uid;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: BookListingTile(
                      title: b.title,
                      author: b.author,
                      condition: b.condition,
                      daysAgo: '',
                      isOwner: isOwner,
                      imageBase64: b.imageBase64,
                    ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class BookListingTile extends StatelessWidget {
  final String title;
  final String author;
  final String condition;
  final String daysAgo;
  final bool isOwner;
  final String? imageBase64; // added

  const BookListingTile({
    super.key,
    required this.title,
    required this.author,
    required this.condition,
    required this.daysAgo,
    this.isOwner = false,
    this.imageBase64,
  });

  Widget _buildBookImage() {
    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(imageBase64!);
        return Image.memory(bytes, width: 120, height: 160, fit: BoxFit.cover);
      } catch (_) {}
    }
    // fallback
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Center(
        child: Text(
          title.split(' ')[0],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color.fromARGB(253, 5, 0, 0),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBookImage(),
        
        const SizedBox(width: 25),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 12, 11, 11),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                author,
                style: TextStyle(fontSize: 14, color: const Color.fromARGB(179, 8, 8, 8)),
              ),
              const SizedBox(height: 8),
              Text(
                condition,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: condition == 'Like New'
                      ? Colors.greenAccent
                      : Colors.grey[300],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.folder_open,
                    size: 16,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    daysAgo,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  if (isOwner)
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Icons.person, size: 16, color: Colors.yellow),
                    ),
                ],
              ),
              
            ],
          ),
        ),
      ],
    );
  }
}
