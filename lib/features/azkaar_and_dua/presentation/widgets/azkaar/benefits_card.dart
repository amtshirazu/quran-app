import 'package:flutter/material.dart';

class BenefitsCard extends StatelessWidget {
  const BenefitsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final benefits = [
      'Brings peace and tranquility to the heart',
      'Strengthens your connection with Allah',
      'Provides protection from harm',
      'Increases blessings in your life',
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4).withOpacity(0.3), // Light yellow
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFF176).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Benefits of Dhikr',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 12),
          ...benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      benefit,
                      style: const TextStyle(fontSize: 14, color: Colors.brown),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
