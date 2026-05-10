import 'package:flutter/material.dart';

Future<String?> showBookmarkDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required bool isPageMode, // New parameter to determine the hint text
  String? initialNote,
}) {
  final controller = TextEditingController(text: initialNote ?? "");

  // Dynamic text based on mode
  final String noteHint = isPageMode
      ? "Add a note to remember why this page is important (optional)"
      : "Add a note to remember why this verse is important (optional)";

  final String textFieldHint = isPageMode
      ? "e.g. Favorite Juz, specific topic, start of my journey..."
      : "e.g. Read when stressed, reminder for prayer, beautiful tafsir...";

  // Colors from your design
  const colorDeepGray = Color(0xFF111827);
  const colorMidGray = Color(0xFF4A4A4A);
  const colorLightGray = Color(0xFF71717A);
  const colorAmber = Color(0xFFD97706);
  const colorTextFieldBG = Color(0xFFF9FAFB);

  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorDeepGray,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.close,
                      color: colorLightGray,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: const TextStyle(
                  color: colorAmber,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                noteHint,
                style: const TextStyle(color: colorMidGray, fontSize: 13),
              ),

              const SizedBox(height: 12),

              // The Styled Text Field
              TextField(
                controller: controller,
                maxLines: 4,
                autofocus: true,
                style: const TextStyle(fontSize: 14, color: colorDeepGray),
                decoration: InputDecoration(
                  hintText: textFieldHint,
                  hintStyle: const TextStyle(
                    color: colorLightGray,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: colorTextFieldBG,
                  contentPadding: const EdgeInsets.all(16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: colorAmber, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: colorMidGray,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: colorAmber,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, controller.text.trim());
                      },
                      child: const Text(
                        "Save Bookmark",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
