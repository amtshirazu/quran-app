import 'package:flutter/material.dart';

Future<String?> showReflectionDialog(
  BuildContext context, {
  required String surahName,
  required int ayahNumber,
  String? initialReflection,
}) {
  final controller = TextEditingController(text: initialReflection ?? "");

  const colorDeepGray = Color(0xFF111827);
  const colorMidGray = Color(0xFF4A4A4A);
  const colorLightGray = Color(0xFF71717A);
  const colorEmerald = Color(0xFF10B981); // Calming green for reflection
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
                  const Text(
                    "Write Your Reflection",
                    style: TextStyle(
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
                "$surahName • Verse $ayahNumber",
                style: const TextStyle(
                  color: colorEmerald,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "What does this verse mean to you? How can you apply it in your life?",
                style: TextStyle(
                  color: colorMidGray,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // The Styled Text Field
              TextField(
                controller: controller,
                maxLines: 6, // Slightly taller for longer reflections
                autofocus: true,
                style: const TextStyle(fontSize: 14, color: colorDeepGray),
                decoration: InputDecoration(
                  hintText: "Write your thoughts and reflections here...",
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
                    borderSide: const BorderSide(
                      color: colorEmerald,
                      width: 1.5,
                    ),
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
                        backgroundColor: colorEmerald,
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
                        "Save Reflection",
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
