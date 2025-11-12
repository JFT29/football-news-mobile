import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:football_news/screens/menu.dart';

class NewsEntryFormPage extends StatefulWidget {
  const NewsEntryFormPage({super.key});

  @override
  State<NewsEntryFormPage> createState() => _NewsEntryFormPageState();
}

class _NewsEntryFormPageState extends State<NewsEntryFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String _title = "";
  String _content = "";
  String _thumbnail = "";
  String _category = "";
  bool _isFeatured = false;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create News Entry'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Title",
                  hintText: "Enter news title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (v) => setState(() => _title = v.trim()),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Title cannot be empty" : null,
              ),
              const SizedBox(height: 12),

              // Content
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Content",
                  hintText: "Write the news content",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                maxLines: 5,
                onChanged: (v) => setState(() => _content = v.trim()),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Content cannot be empty"
                    : null,
              ),
              const SizedBox(height: 12),

              // Thumbnail URL
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Thumbnail (URL)",
                  hintText: "https://example.com/image.jpg",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (v) => setState(() => _thumbnail = v.trim()),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Thumbnail URL cannot be empty";
                  }
                  final ok = Uri.tryParse(v)?.hasAbsolutePath ?? false;
                  if (!ok || !(v.startsWith("http://") || v.startsWith("https://"))) {
                    return "Please enter a valid URL";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Category
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Category",
                  hintText: "e.g., Ball, Boots, Protection",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (v) => setState(() => _category = v.trim()),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Category cannot be empty" : null,
              ),
              const SizedBox(height: 12),

              // Featured
              SwitchListTile(
                title: const Text("Featured"),
                value: _isFeatured,
                onChanged: (b) => setState(() => _isFeatured = b),
              ),
              const SizedBox(height: 16),

              // Save button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Make request
                      final response = await request.postJson(
                        "http://localhost:8000/create-flutter/",
                        jsonEncode({
                          "title": _title,
                          "content": _content,
                          "thumbnail": _thumbnail,
                          "category": _category,
                          "is_featured": _isFeatured,
                        }),
                      );

                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("News successfully saved!"),
                            ),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyHomePage()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Something went wrong, please try again."),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 16),
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
