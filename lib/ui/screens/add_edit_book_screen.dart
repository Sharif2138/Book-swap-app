import 'dart:convert';
import 'dart:io' show File;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/book_model.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';

class AddEditBookScreen extends StatefulWidget {
  final Book? book;
  const AddEditBookScreen({super.key, this.book});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  String condition = 'Good';
  String? _imageBase64;
  bool _loading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _title.text = widget.book!.title;
      _author.text = widget.book!.author;
      condition = widget.book!.condition;
      _imageBase64 = widget.book!.imageBase64;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      String base64Image;

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        base64Image = base64Encode(bytes);
      } else {
        final file = File(picked.path);
        final compressed = await FlutterImageCompress.compressAndGetFile(
          file.path,
          '${file.path}_compressed.jpg',
          quality: 70,
          minWidth: 800,
          minHeight: 800,
        );
        base64Image = base64Encode(await compressed!.readAsBytes());
      }

      setState(() {
        _imageBase64 = base64Image;
        _isUploading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image upload failed')));
      setState(() => _isUploading = false);
    }
  }

  Widget _imagePreview() {
    if (_imageBase64 != null) {
      return Image.memory(
        base64Decode(_imageBase64!),
        height: 180,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Icon(Icons.image, size: 60, color: Colors.grey),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final bookProv = Provider.of<BookProvider>(context, listen: false);

    try {
      if (widget.book == null) {
        final id = const Uuid().v4();
        final newBook = Book(
          id: id,
          title: _title.text.trim(),
          author: _author.text.trim(),
          condition: condition,
          imageBase64: _imageBase64,
          ownerId: auth.user!.uid,
          createdAt: Timestamp.now(),
        );
        await bookProv.addBook(newBook);
      } else {
        final updated = Book(
          id: widget.book!.id,
          title: _title.text.trim(),
          author: _author.text.trim(),
          condition: condition,
          imageBase64: _imageBase64,
          ownerId: widget.book!.ownerId,
          swapState: widget.book!.swapState,
          createdAt: widget.book!.createdAt,
        );
        await bookProv.updateBook(updated);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final bookProv = Provider.of<BookProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Book?'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      try {
        await bookProv.deleteBook(widget.book!.id);
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner =
        widget.book != null &&
        Provider.of<AuthProvider>(context).user!.uid == widget.book!.ownerId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Add Book' : 'Edit Book'),
        centerTitle: true,
        toolbarHeight: 90,
        backgroundColor: const Color.fromARGB(255, 1, 6, 37),
        foregroundColor: Colors.white,
        actions: isOwner && widget.book != null
            ? [IconButton(icon: const Icon(Icons.delete), onPressed: _delete)]
            : null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _title,
                      decoration: InputDecoration(
                        labelText: 'Book Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _author,
                      decoration: InputDecoration(
                        labelText: 'Author',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: condition,
                      decoration: InputDecoration(
                        labelText: 'Condition',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      items: const ['New', 'Like New', 'Good', 'Used']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => condition = v!),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickImage,
                      child: _isUploading
                          ? const Center(child: CircularProgressIndicator())
                          : _imagePreview(),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.book == null ? 'Add Book' : 'Save Changes',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
