import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/states/dua_provider.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/widgets/dua/dua_card.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/widgets/dua/dua_category_toggle.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/widgets/dua/dua_header.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/widgets/dua/dua_search_field.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/widgets/dua/dua_section_title.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/widgets/dua/power_of_dua_card.dart';

class DuasScreen extends ConsumerStatefulWidget {
  const DuasScreen({super.key});

  @override
  ConsumerState<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends ConsumerState<DuasScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final duasAsync = searchQuery.isEmpty
        ? ref.watch(allDuasProvider)
        : ref.watch(filteredDuasProvider(searchQuery));

    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF7),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DuaHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              children: [
                const PowerOfDuaCard(),
                const SizedBox(height: 16),

                /// Category Toggle (Quranic Duas vs Witr & Qunoot)
                const DuaCategoryToggle(),
                const SizedBox(height: 16),

                /// Search Input Field Element
                DuaSearchField(
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
                const SizedBox(height: 20),

                /// Section Label Title Block
                const DuaSectionTitle(),
                const SizedBox(height: 12),

                /// Reactive Query List Rendering View
                duasAsync.when(
                  data: (duas) {
                    if (duas.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            "No matching supplications found.",
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: duas.length,
                      itemBuilder: (context, index) =>
                          DuaCard(dua: duas[index]),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(
                        color: AppColors.emerald600,
                      ),
                    ),
                  ),
                  error: (err, _) => Center(
                    child: Text(
                      "Error fetching records: $err",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
