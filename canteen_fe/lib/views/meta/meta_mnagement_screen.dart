// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:canteen_fe/core/constants/api_endpoints.dart';
import 'package:canteen_fe/providers/token_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class MetaManagementScreen extends ConsumerStatefulWidget {
  final String type; // 'division' | 'department' | 'designation'
  final String? mode; // optional: 'create' | 'rename' | 'delete'

  const MetaManagementScreen({super.key, required this.type, this.mode});

  @override
  ConsumerState<MetaManagementScreen> createState() =>
      _MetaManagementScreenState();
}

class _MetaManagementScreenState extends ConsumerState<MetaManagementScreen> {
  // Palette (matches login/signup)
  static const _brandPrimary = Color(0xFF4F46E5); // Indigo 600
  static const _brandPrimaryDark = Color(0xFF4338CA); // Indigo 700
  static const _pageBg = Color(0xFFF6F7FB); // very light slate
  static const _cardBg = Colors.white;
  static const _inputFill = Color(0xFFF9FAFB);

  final TextEditingController _createCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filtered = [];

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

  String updateUrl(String id) {
    switch (widget.type) {
      case 'department':
        return updateDepartmentUrl(id);
      case 'designation':
        return updateDesignationUrl(id);
      default:
        return updateDivisionUrl(id);
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

  IconData get leadingIcon {
    switch (widget.type) {
      case 'department':
        return Icons.account_tree_rounded;
      case 'designation':
        return Icons.work_outline_rounded;
      default:
        return Icons.apartment_rounded;
    }
  }

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  void showToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> fetchItems() async {
    final token = ref.read(tokenProvider);
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse(getAllUrl),
        headers: _headers(token!),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        // ✅ backend returns { count: X, items: [...] }
        final list =
            (data['items'] as List)
                .map<Map<String, dynamic>>(
                  (e) => Map<String, dynamic>.from(e as Map),
                )
                .toList();

        setState(() {
          items = list;
          _applyFilter(_searchCtrl.text);
        });
      } else {
        debugPrint('fetchItems() error ${res.statusCode}: ${res.body}');
        showToast('Failed to fetch $title (${res.statusCode})');
      }
    } catch (e) {
      debugPrint('fetchItems() exception: $e');
      showToast('Failed to fetch $title');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> addItem() async {
    final text = _createCtrl.text.trim();
    if (text.isEmpty) return;

    final token = ref.read(tokenProvider);
    try {
      final res = await http.post(
        Uri.parse(createUrl()),
        headers: _headers(token!),
        body: jsonEncode({'name': text}),
      );
      if (res.statusCode == 201) {
        _createCtrl.clear();
        await fetchItems();
        showToast('$title added');
      } else {
        showToast('Failed to add $title');
      }
    } catch (_) {
      showToast('Failed to add $title');
    }
  }

  Future<void> renameItem(String id, String currentName) async {
    final ctrl = TextEditingController(text: currentName);
    final newName = await showDialog<String?>(
      context: context,
      builder:
          (ctx) => _RenameDialog(
            title: 'Rename $title',
            controller: ctrl,
            hint: 'Enter new $title name',
          ),
    );

    if (newName == null) return;
    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == currentName) return;

    final token = ref.read(tokenProvider);
    try {
      final res = await http.put(
        Uri.parse(updateUrl(id)),
        headers: _headers(token!),
        body: jsonEncode({'name': trimmed}),
      );
      if (res.statusCode == 200) {
        await fetchItems();
        showToast('$title updated');
      } else {
        showToast('Failed to update $title');
      }
    } catch (_) {
      showToast('Failed to update $title');
    }
  }

  Future<void> deleteItem(String id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Delete $title'),
            content: Text('Are you sure you want to delete "$name"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (ok != true) return;

    final token = ref.read(tokenProvider);
    try {
      final res = await http.delete(
        Uri.parse(deleteUrl(id)),
        headers: _headers(token!),
      );
      if (res.statusCode == 200) {
        await fetchItems();
        showToast('$title deleted');
      } else {
        showToast('Failed to delete $title');
      }
    } catch (_) {
      showToast('Failed to delete $title');
    }
  }

  void _applyFilter(String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) {
      filtered = List.of(items);
    } else {
      filtered =
          items.where((e) {
            final name = (e['name'] ?? '').toString().toLowerCase();
            return name.contains(query);
          }).toList();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchItems();

    if (widget.mode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // You can use mode to pre-open certain flows later
        // For now we show a subtle hint only
        // showToast('Mode: ${widget.mode}');
      });
    }

    _searchCtrl.addListener(() => _applyFilter(_searchCtrl.text));
  }

  @override
  void dispose() {
    _createCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 720;

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '$title Management',
          style: const TextStyle(color: Color(0xFF0F172A)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: _blurBlob(const Color(0xFFEEF2FF)),
            ),
            Positioned(
              bottom: -140,
              left: -100,
              child: _blurBlob(const Color(0xFFE0E7FF)),
            ),
            Column(
              children: [
                // Create / Search Card
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 24 : 16,
                    vertical: 12,
                  ),
                  child: _NeumorphicCard(
                    background: _cardBg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [_brandPrimary, _brandPrimaryDark],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _brandPrimary.withOpacity(0.28),
                                    offset: const Offset(0, 8),
                                    blurRadius: 18,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.settings_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Manage $title',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Create Row
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _createCtrl,
                                textInputAction: TextInputAction.done,
                                decoration: _inputDecoration(
                                  context,
                                  hint: 'Enter $title name',
                                  icon: Icons.add_rounded,
                                ),
                                onSubmitted: (_) => addItem(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: addItem,
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                              ),
                              label: Text('Add $title'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _brandPrimary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Search Bar
                        TextField(
                          controller: _searchCtrl,
                          textInputAction: TextInputAction.search,
                          decoration: _inputDecoration(
                            context,
                            hint: 'Search $title',
                            icon: Icons.search_rounded,
                            suffix: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _searchCtrl,
                              builder: (_, value, __) {
                                if (value.text.isEmpty)
                                  return const SizedBox.shrink();
                                return IconButton(
                                  tooltip: 'Clear',
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _applyFilter('');
                                  },
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    color: Color(0xFF94A3B8),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // List
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16),
                    child: _NeumorphicCard(
                      background: _cardBg,
                      child:
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : RefreshIndicator(
                                onRefresh: fetchItems,
                                child:
                                    filtered.isEmpty
                                        ? _EmptyState(
                                          title: 'No $title found',
                                          subtitle:
                                              'Try adding a new $title or change your search.',
                                          icon: leadingIcon,
                                        )
                                        : ListView.separated(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          padding: const EdgeInsets.fromLTRB(
                                            8,
                                            8,
                                            8,
                                            16,
                                          ),
                                          itemCount: filtered.length,
                                          separatorBuilder:
                                              (_, __) =>
                                                  const SizedBox(height: 8),
                                          itemBuilder: (context, i) {
                                            final item = filtered[i];
                                            final name =
                                                (item['name'] ?? '').toString();
                                            final id =
                                                (item['_id'] ?? '').toString();

                                            return Card(
                                              elevation: 0,
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                side: const BorderSide(
                                                  color: Color(0xFFE5E7EB),
                                                ),
                                              ),
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundColor: const Color(
                                                    0xFFEFF6FF,
                                                  ),
                                                  child: Icon(
                                                    leadingIcon,
                                                    color: _brandPrimary,
                                                  ),
                                                ),
                                                title: Text(
                                                  name,
                                                  style: const TextStyle(
                                                    color: Color(0xFF0F172A),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                trailing: Wrap(
                                                  spacing: 6,
                                                  children: [
                                                    Tooltip(
                                                      message: 'Rename',
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons
                                                              .drive_file_rename_outline_rounded,
                                                          color: Color(
                                                            0xFF0EA5E9,
                                                          ),
                                                        ), // sky-500
                                                        onPressed:
                                                            () => renameItem(
                                                              id,
                                                              name,
                                                            ),
                                                      ),
                                                    ),
                                                    Tooltip(
                                                      message: 'Delete',
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons
                                                              .delete_forever_rounded,
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                        onPressed:
                                                            () => deleteItem(
                                                              id,
                                                              name,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Input decoration matching app style
  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
      suffixIcon: suffix,
      filled: true,
      fillColor: _inputFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _brandPrimary, width: 1.4),
      ),
    );
  }

  // Decorative blurred blob
  Widget _blurBlob(Color color) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 90,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

/// Soft, elegant card (neumorphic-ish)
class _NeumorphicCard extends StatelessWidget {
  final Widget child;
  final Color background;

  const _NeumorphicCard({required this.child, this.background = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000), // 10% black
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: Color(0x0D000000), // 5% black
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: child,
    );
  }
}

/// Pretty empty state
class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFFEFF6FF),
              child: Icon(
                icon,
                color: _MetaManagementScreenState._brandPrimary,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rename dialog
class _RenameDialog extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String hint;

  const _RenameDialog({
    required this.title,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        inputFormatters: [
          // prevent accidental newlines/pastes with line breaks
          FilteringTextInputFormatter.singleLineFormatter,
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
