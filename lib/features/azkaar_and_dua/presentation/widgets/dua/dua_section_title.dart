import 'package:flutter/material.dart';

class DuaSectionTitle extends StatelessWidget {
  const DuaSectionTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "All Duas",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(
              0xFF0F2E3A,
            ), // Dark blue navy font variant from snapshot
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Essential supplications for every need",
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }
}
