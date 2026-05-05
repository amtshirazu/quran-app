import 'package:flutter/material.dart';
import 'package:quran_app/features/reflection/presentation/widgets/reflection_header.dart';
import 'package:quran_app/features/reflection/presentation/widgets/reflection_body.dart';

class ReflectionScreen extends StatelessWidget {
  const ReflectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Matching your app's background color
      backgroundColor: const Color(0xFFFFFBEB),
      body: Column(
        children: [
          // The Header (includes Search bar)
          const ReflectionHeader(),

          // The Body (Scrollable content)
          const Expanded(child: ReflectionBody()),
        ],
      ),
    );
  }
}
