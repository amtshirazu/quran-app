import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';

class TopicDetailScreen extends StatelessWidget {
  final String topicLabel;

  const TopicDetailScreen({
    super.key,
    required this.topicLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E48),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          topicLabel,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.collections_bookmark_outlined,
                size: 64,
                color: AppColors.emerald600,
              ),
              const SizedBox(height: 16),
              Text(
                'Topic: $topicLabel',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Showing verses and supplications related to $topicLabel.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
