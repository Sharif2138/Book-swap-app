class BookModel {
  String id;
  String title;
  String author;
  String condition;
  String coverImage;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    required this.coverImage,
  });

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      condition: map['condition'],
      coverImage: map['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'author': author, 'condition': condition, 'coverImage': coverImage};
  }
}
