import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:football_news/widgets/left_drawer.dart';

class NewsFormPage extends StatefulWidget {
  const NewsFormPage({super.key});

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = "";
  String _content = "";
  String _category = "update";
  String _thumbnail = "";
  bool _isFeatured = false;

  final List<String> _categories = const [
    'transfer',
    'update',
    'exclusive',
    'match',
    'rumor',
    'analysis',
  ];

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _title = "";
      _content = "";
      _category = "update";
      _thumbnail = "";
      _isFeatured = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add News Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Title ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "News Title",
                    labelText: "News Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => _title = value.trim(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Title cannot be empty!";
                    }
                    return null;
                  },
                ),
              ),

              // === Content ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "News Content",
                    labelText: "News Content",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (value) => _content = value.trim(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Content cannot be empty!";
                    }
                    if (value.trim().length < 20) {
                      return "Please write at least 20 characters.";
                    }
                    return null;
                  },
                ),
              ),

              // === Category ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  // <- use initialValue (fixes deprecated 'value')
                  initialValue: _category,
                  items: _categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child:
                              Text('${cat[0].toUpperCase()}${cat.substring(1)}'),
                        ),
                      )
                      .toList(),
                  onChanged: (newValue) => setState(() {
                    _category = newValue ?? "update";
                  }),
                ),
              ),

              // === Thumbnail URL ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Thumbnail URL (optional)",
                    labelText: "Thumbnail URL",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (value) => _thumbnail = value.trim(),
                  validator: (value) {
                    if (value == null || value.isEmpty) return null; // optional
                    final u = Uri.tryParse(value);
                    if (u == null ||
                        !(u.isScheme('http') || u.isScheme('https'))) {
                      return "Please enter a valid http(s) URL or leave empty.";
                    }
                    return null;
                  },
                ),
              ),

              // === Is Featured ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SwitchListTile(
                  title: const Text("Mark as Featured News"),
                  value: _isFeatured,
                  onChanged: (value) => setState(() {
                    _isFeatured = value;
                  }),
                ),
              ),

              // === Save Button ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      // <- use WidgetStatePropertyAll (fixes deprecation)
                      backgroundColor:
                          const WidgetStatePropertyAll(Colors.indigo),
                      foregroundColor:
                          const WidgetStatePropertyAll(Colors.white),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final payload = {
                        'title': _title,
                        'content': _content,
                        'category': _category,
                        'thumbnail': _thumbnail, // may be empty
                        'is_featured': _isFeatured.toString(),
                      };

                      try {
                        final resp = await request.post(
                          'http://127.0.0.1:8000/create-flutter/',
                          payload,
                        );

                        // Guard UI work after await (fixes use_build_context_synchronously)
                        if (!context.mounted) return;

                        final ok = (resp is Map &&
                            (resp['status'] == true ||
                                resp['status'] == 'success'));
                        final message = (resp is Map
                                ? (resp['message'] ?? 'Saved.')
                                : 'Saved.')
                            .toString();

                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(ok
                                ? 'News saved successfully!'
                                : 'Save failed'),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Title: $_title'),
                                  Text(
                                      'Content: ${_content.length > 100 ? '${_content.substring(0, 100)}...' : _content}'),
                                  Text('Category: $_category'),
                                  Text(
                                      'Thumbnail: ${_thumbnail.isEmpty ? '(none)' : _thumbnail}'),
                                  Text(
                                      'Featured: ${_isFeatured ? "Yes" : "No"}'),
                                  const SizedBox(height: 8),
                                  Text(message),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );

                        if (ok) {
                          _resetForm();
                        }
                      } catch (e) {
                        // Guard UI again (fixes second lint)
                        if (!context.mounted) return;
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Network error'),
                            content: Text(e.toString()),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: const Text("Save"),
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
