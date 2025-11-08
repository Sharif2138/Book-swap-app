import 'package:flutter/material.dart';


// --- Main Screen Widget ---
class BrowseListingsScreen extends StatelessWidget {
  const BrowseListingsScreen({super.key});

  // A simple list to hold basic listing data (Title, Cover Color)
  final List<Map<String, dynamic>> listings = const [
    {
      'title': 'Data Structures & Algorithms',
      'author': 'Themail V Dermon',
      'condition': 'Like New',
      'daysAgo': '3 days ago',
      'coverColor': Color(0xFF262626),
    },
    {
      'title': 'Operating Systems',
      'author': 'John Doe',
      'condition': 'Used',
      'daysAgo': '2 days ago',
      'coverColor': Color(0xFF0D47A1),
    },
    {
      'title': 'Operating Systems',
      'author': 'Jane Smith',
      'condition': 'Used',
      'daysAgo': '1 day ago',
      'coverColor': Color(0xFF455A64),
    },
    // Adding a few more items to ensure scrollability is demonstrated
    {
      'title': 'Computer Networks',
      'author': 'Alex King',
      'condition': 'Like New',
      'daysAgo': '1 day ago',
      'coverColor': Color(0xFFC62828),
    },
    {
      'title': 'Database Systems',
      'author': 'Sarah Lee',
      'condition': 'Used',
      'daysAgo': '5 days ago',
      'coverColor': Color(0xFF004D40),
    },
  ];

  void _showPostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Post New Book Listing'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Fill in the details for your book:'),
                SizedBox(height: 10),
                TextField(decoration: InputDecoration(labelText: 'Book Title')),
                TextField(decoration: InputDecoration(labelText: 'Price')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Post'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90.0,
        backgroundColor:  const Color.fromARGB(255, 1, 6, 37),
        title: const Text('Browse Listings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      // The body is scrollable by default using ListView.separated
      body: ListView.separated(
        itemCount: listings.length,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: Color(0xFFF0F0F0),
          indent: 10,
          endIndent: 10,
        ),
        itemBuilder: (context, index) {
          // Pass map data to the tile widget
          return BookListingTile(listing: listings[index]);
        },
      ),

      // Floating Action Button for posting books
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPostDialog(context),
        label: const Text('Post'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.yellowAccent,
        foregroundColor: Colors.black,
      ),
      // FAB position: bottom right by default when BottomNavigationBar is absent
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// --- Custom Widget for a single book listing (Tile) ---
class BookListingTile extends StatelessWidget {
  final Map<String, dynamic> listing;
  const BookListingTile({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _BookCover(
            title: listing['title'],
            coverColor: listing['coverColor'] as Color,
          ),
          const SizedBox(width: 15.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  listing['title'],
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  listing['author'],
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8.0),
                Text(
                  listing['condition'],
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: listing['condition'] == 'Like New'
                        ? const Color(0xFF1B5E20)
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.folder_open,
                      size: 16.0,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5.0),
                    Text(
                      listing['daysAgo'],
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Simplified Book Cover Widget ---
class _BookCover extends StatelessWidget {
  final String title;
  final Color coverColor;
  const _BookCover({required this.title, required this.coverColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        color: coverColor,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title.split(' ')[0],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (title.contains('&'))
                Text(
                  title.split(' ')[2],
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
