import 'package:flutter/material.dart';

Future<String?> showBookmarkDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  String? initialNote,
}) {
  final controller = TextEditingController(text: initialNote ?? "");
  final String noteHint =
      "Add a note to remember why this verse is important to you (optional)";

  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add Bookmark",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  noteHint,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "e.g. Read when stressed, reminder for prayer...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                      ),
                      onPressed: () {
                        Navigator.pop(context, controller.text.trim());
                      },
                      child: const Text("Save Bookmark"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
