import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MushafPageShimmer extends StatelessWidget {
  const MushafPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[900]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(15, (index) {
            // Randomize the width of the first and last lines for a natural look
            double widthFactor = 1.0;
            if (index == 0) widthFactor = 0.6; // First line often shorter
            if (index == 14) widthFactor = 0.4; // Last line often shorter

            return Container(
              height: 20,
              width: MediaQuery.of(context).size.width * widthFactor,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ),
    );
  }
}
