import 'package:flutter/material.dart';

class PropheticTipCard extends StatelessWidget {
  const PropheticTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFF176).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Tip',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'The Prophet ﷺ said: "Whoever says \'SubhanAllahi wa bihamdihi\' (Glory and praise be to Allah) one hundred times a day, his sins will be forgiven even if they are like the foam of the sea."',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '- Sahih Al-Bukhari and Muslim',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.brown,
            ),
          ),
        ],
      ),
    );
  }
}
