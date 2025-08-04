import 'package:flutter/material.dart';

Future<String?> showSearchableBottomSheet(
    BuildContext context, List<String> items, String title) {
  final controller = TextEditingController();
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      List<String> filtered = List.from(items);
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Select $title", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Search...'),
                  onChanged: (val) {
                    setState(() {
                      filtered = items
                          .where((e) => e.toLowerCase().contains(val.toLowerCase()))
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      return ListTile(
                        title: Text(filtered[i]),
                        onTap: () => Navigator.of(context).pop(filtered[i]),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
