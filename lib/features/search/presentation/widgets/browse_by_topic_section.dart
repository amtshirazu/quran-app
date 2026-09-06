import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/search_provider.dart';
import '../../domain/model/topic_category.dart';

class BrowseByTopicSection extends ConsumerWidget {
  final ValueChanged<TopicCategory> onTopicSelected;

  const BrowseByTopicSection({super.key, required this.onTopicSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Section Header Row

        Text(
          'BROWSE BY TOPIC',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2421), // Dark charcoal
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 14),

        /// Horizontal Scrolling Cards Row
        SizedBox(
          height: 102,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: kTopicCategories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final topic = kTopicCategories[index];
              return _TopicCard(
                topic: topic,
                onTap: () => onTopicSelected(topic),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  final TopicCategory topic;
  final VoidCallback onTap;

  const _TopicCard({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          /// Square soft-beige container
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFEFECE6), // Soft beige
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              topic.icon,
              color: const Color(0xFF114B3E), // Deep green icon
              size: 28,
            ),
          ),
          const SizedBox(height: 6),

          /// 1-line label
          SizedBox(
            width: 72,
            child: Text(
              topic.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2421),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
