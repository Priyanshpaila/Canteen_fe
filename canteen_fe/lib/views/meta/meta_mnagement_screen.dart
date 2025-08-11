// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:canteen_fe/core/constants/api_endpoints.dart';
import 'package:canteen_fe/providers/token_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class MetaManagementScreen extends ConsumerStatefulWidget {
  final String type; // 'division' | 'department' | 'designation'
  const MetaManagementScreen({super.key, required this.type});

  @override
  ConsumerState<MetaManagementScreen> createState() =>
      _MetaManagementScreenState();
}

class _MetaManagementScreenState extends ConsumerState<MetaManagementScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> items = [];
  bool isLoading = false;

  String get title => widget.type[0].toUpperCase() + widget.type.substring(1);

  String get getAllUrl {
    switch (widget.type) {
      case 'department':
        return getAllDepartmentsUrl;
      case 'designation':
        return getAllDesignationsUrl;
      default:
        return getAllDivisionsUrl;
    }
  }

  String createUrl() {
    switch (widget.type) {
      case 'department':
        return createDepartmentUrl;
      case 'designation':
        return createDesignationUrl;
      default:
        return createDivisionUrl;
    }
  }

  String deleteUrl(String id) {
    switch (widget.type) {
      case 'department':
        return deleteDepartmentUrl(id);
      case 'designation':
        return deleteDesignationUrl(id);
      default:
        return deleteDivisionUrl(id);
    }
  }

  void showToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<void> fetchItems() async {
    final token = ref.read(tokenProvider);

    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse(getAllUrl),
        headers: _headers(token!),
      );
      if (res.statusCode == 200) {
        setState(() => items = json.decode(res.body));
      } else {
        showToast('Failed to fetch $title');
      }
    } catch (_) {
      showToast('Failed to fetch $title');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> addItem() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final token = ref.read(tokenProvider);

    try {
      final res = await http.post(
        Uri.parse(createUrl()),
        headers: _headers(token!),
        body: jsonEncode({'name': text}),
      );
      if (res.statusCode == 201) {
        _controller.clear();
        fetchItems();
        showToast('$title added');
      } else {
        showToast('Failed to add $title');
      }
    } catch (_) {
      showToast('Failed to add $title');
    }
  }

  Future<void> deleteItem(String id) async {
    final token = ref.read(tokenProvider);

    try {
      final res = await http.delete(
        Uri.parse(deleteUrl(id)),
        headers: _headers(token!),
      );
      if (res.statusCode == 200) {
        fetchItems();
        showToast('$title deleted');
      } else {
        showToast('Failed to delete $title');
      }
    } catch (_) {
      showToast('Failed to delete $title');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$title Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter $title name',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: addItem,
                icon: const Icon(Icons.add),
                label: Text('Add $title'),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item['name']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteItem(item['_id']),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
