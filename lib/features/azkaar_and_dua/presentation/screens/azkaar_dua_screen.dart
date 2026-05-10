import 'package:flutter/material.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/widgets/azkaar_dua_appbar.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/widgets/benefits_card.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/widgets/remembrance_card.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/widgets/selection_card.dart';

class AzkaarDuaScreen extends StatelessWidget {
  const AzkaarDuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFBFDFF,
      ), // Very light blue-grey background
      appBar: const AzkaarDuaAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const RemembranceCard(),

            // AZKAAR SELECTION
            SelectionCard(
              title: 'Azkaar',
              subtitle:
                  'Remembrance and phrases from the Sunnah to say throughout your day',
              icon: Icons.auto_awesome_rounded,
              tags: const ['Morning & Evening', 'After Salah', 'Before Sleep'],
              onTap: () {
                // Navigate to full list of 11 Categories
              },
            ),

            // DUA SELECTION (Balanced with 3 tags)
            SelectionCard(
              title: 'Duas',
              subtitle: 'Supplications from the Holy Quran for every need',
              icon: Icons.menu_book_rounded,
              // Balanced with 3 tags as discussed
              tags: const [
                'Prophetic (Rabbana)',
                'For Success',
                'For Protection',
              ],
              onTap: () {
                // Navigate to Quranic Duas section
              },
            ),

            const BenefitsCard(),

            // Adding a little extra padding at the bottom for scroll breathability
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
