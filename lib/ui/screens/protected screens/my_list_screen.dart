import 'package:flutter/material.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data representing the user's current book listings and their status
    final myBooks = [
      {
        'title': 'Intro to Algorithms',
        'author': 'Cormen',
        'condition': 'Like New',
        'time': '3h ago',
        'image':
            'https://via.placeholder.com/60/FFD700/000000?text=ALGO', // Placeholder with Gold background
        'swap': false, // No current swap/offer activity
      },
      {
        'title': 'Data Science for Dummies',
        'author': 'Smith',
        'condition': 'Good',
        'time': '5h ago',
        'image':
            'https://via.placeholder.com/60/4CAF50/FFFFFF?text=DATA', // Placeholder with Green background
        'swap': true, // Indicates a pending swap/offer
      },
      {
        'title': 'Operating Systems Concepts',
        'author': 'Silberschatz',
        'condition': 'Fair',
        'time': '1d ago',
        'image':
            'https://via.placeholder.com/60/2196F3/FFFFFF?text=OSC', // Placeholder with Blue background
        'swap': false,
      },
      {
        'title': 'Design Patterns',
        'author': 'Gamma',
        'condition': 'Like New',
        'time': '2d ago',
        'image':
            'https://via.placeholder.com/60/FF9800/000000?text=DP', // Placeholder with Orange background
        'swap': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My List & Offers'),
        toolbarHeight: 90.0,
        centerTitle: true,
        // Setting the colors to match the previous theme's style
        backgroundColor: const Color.fromARGB(255, 1, 6, 37),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: myBooks.length,
        itemBuilder: (context, index) {
          final book = myBooks[index];
          // Determine the indicator color based on the 'swap' status
          final bool hasSwapOffer = book['swap'] as bool;
          final Color indicatorColor = hasSwapOffer
              ? Colors.green
              : Colors.grey[400]!;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            elevation: 2, // Slight elevation for depth
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Book Cover Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      book['image'] as String,
                      width: 60,
                      height: 80,
                      fit: BoxFit.cover,
                      // Fallback/error handling for image loading
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 80,
                        color: Colors.deepPurple[100],
                        child: const Center(
                          child: Icon(
                            Icons.menu_book,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  // 2. Listing Details (Title, Author, Condition, Time)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book['author'] as String,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Condition Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors
                                    .deepPurple[50], // Lighter tag background
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                book['condition'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple[700],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Time Posted/Updated
                            Text(
                              'Posted: ${book['time'] as String}',
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

                  // 3. Swap/Offer Indicator Icon
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        hasSwapOffer
                            ? Icons.swap_horizontal_circle_outlined
                            : Icons.hourglass_empty,
                        color: indicatorColor,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasSwapOffer ? 'Offer!' : 'No Offers',
                        style: TextStyle(
                          fontSize: 11,
                          color: indicatorColor,
                          fontWeight: FontWeight.w500,
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
