import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';

class AzkarItemCard extends StatelessWidget {
  final AzkarItem item;
  const AzkarItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Clean white card
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Arabic Text
            Text(
              item.item,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.8,
                color: Color(0xFF2D3436),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: Color(0xFFE0F2F1), thickness: 1),
            ),
            // Translation
            Text(
              item.translation,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF636E72),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            // Reference Tag
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.reference,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF009688),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
