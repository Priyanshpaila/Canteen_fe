import 'package:flutter/material.dart';

/// Beautiful searchable bottom sheet with soft shadows, pill search bar,
/// and elegant list tiles. Returns the selected string (or null if dismissed).
///
/// Usage:
/// final result = await showSearchableBottomSheet(context, items, 'Division', icon: Icons.apartment_rounded);
Future<String?> showSearchableBottomSheet(
  BuildContext context,
  List<String> options,
  String title, {
  IconData icon = Icons.list_alt_rounded,
}) async {
  final TextEditingController searchCtrl = TextEditingController();
  final ValueNotifier<List<String>> filtered = ValueNotifier<List<String>>(
    List.of(options),
  );

  void applyFilter(String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) {
      filtered.value = List.of(options);
    } else {
      filtered.value =
          options.where((e) => e.toLowerCase().contains(query)).toList();
    }
  }

  // Palette (matches login/signup screens)
  const brandPrimary = Color(0xFF4F46E5); // Indigo 600
  const brandPrimaryDark = Color(0xFF4338CA); // Indigo 700
  const cardBg = Colors.white;
  const inputFill = Color(0xFFF9FAFB);

  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final media = MediaQuery.of(ctx);
      final isTall = media.size.height > 700;

      return GestureDetector(
        onTap: () => FocusScope.of(ctx).unfocus(),
        child: Stack(
          children: [
         
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: media.viewInsets.bottom,
                top: 12,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.only(bottom: isTall ? 12 : 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBg,
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
                      child: DraggableScrollableSheet(
                        initialChildSize: media.size.height < 720 ? 0.75 : 0.6,
                        minChildSize: 0.45,
                        maxChildSize: 0.95,
                        expand: false,
                        builder: (context, controller) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Grab handle
                              const SizedBox(height: 8),
                              Container(
                                width: 42,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [
                                            brandPrimary,
                                            brandPrimaryDark,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: brandPrimary.withOpacity(
                                              0.28,
                                            ),
                                            offset: const Offset(0, 8),
                                            blurRadius: 18,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Icon(icon, color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Select $title",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          ValueListenableBuilder<List<String>>(
                                            valueListenable: filtered,
                                            builder:
                                                (_, list, __) => Text(
                                                  "${list.length} item${list.length == 1 ? '' : 's'}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: const Color(
                                                          0xFF64748B,
                                                        ),
                                                      ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: "Close",
                                      onPressed:
                                          () => Navigator.pop(context, null),
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Search bar
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: TextField(
                                  controller: searchCtrl,
                                  onChanged: applyFilter,
                                  textInputAction: TextInputAction.search,
                                  decoration: InputDecoration(
                                    hintText: "Search $title",
                                    prefixIcon: const Icon(
                                      Icons.search_rounded,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    suffixIcon: ValueListenableBuilder<
                                      TextEditingValue
                                    >(
                                      valueListenable: searchCtrl,
                                      builder: (_, value, __) {
                                        if (value.text.isEmpty) {
                                          return const SizedBox.shrink();
                                        }
                                        return IconButton(
                                          tooltip: "Clear",
                                          onPressed: () {
                                            searchCtrl.clear();
                                            applyFilter('');
                                          },
                                          icon: const Icon(
                                            Icons.clear_rounded,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        );
                                      },
                                    ),
                                    filled: true,
                                    fillColor: inputFill,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: brandPrimary,
                                        width: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // List
                              Expanded(
                                child: ValueListenableBuilder<List<String>>(
                                  valueListenable: filtered,
                                  builder: (_, list, __) {
                                    if (list.isEmpty) {
                                      return _EmptyState(
                                        title: "No results",
                                        subtitle:
                                            "Try a different search term.",
                                      );
                                    }
                                    return ListView.separated(
                                      controller: controller,
                                      padding: const EdgeInsets.fromLTRB(
                                        8,
                                        8,
                                        8,
                                        16,
                                      ),
                                      itemBuilder: (_, i) {
                                        final item = list[i];
                                        return Card(
                                          elevation: 0,
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            side: const BorderSide(
                                              color: Color(0xFFE5E7EB),
                                            ),
                                          ),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              radius: 18,
                                              backgroundColor: const Color(
                                                0xFFEFF6FF,
                                              ),
                                              child: Icon(
                                                icon,
                                                color: brandPrimary,
                                                size: 20,
                                              ),
                                            ),
                                            title: Text(
                                              item,
                                              style: const TextStyle(
                                                color: Color(0xFF0F172A),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            trailing: const Icon(
                                              Icons.chevron_right_rounded,
                                              color: Color(0xFF94A3B8),
                                            ),
                                            onTap:
                                                () => Navigator.pop(
                                                  context,
                                                  item,
                                                ),
                                          ),
                                        );
                                      },
                                      separatorBuilder:
                                          (_, __) => const SizedBox(height: 8),
                                      itemCount: list.length,
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Widget _blurBlob(Color color) {
//   return Container(
//     width: 200,
//     height: 200,
//     decoration: BoxDecoration(
//       shape: BoxShape.circle,
//       color: color,
//       boxShadow: [
//         BoxShadow(
//           color: color.withOpacity(0.6),
//           blurRadius: 80,
//           spreadRadius: 16,
//         ),
//       ],
//     ),
//   );
// }

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 56,
              color: Color(0xFF94A3B8),
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
