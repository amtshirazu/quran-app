import 'package:flutter/material.dart';

import '../../../../domain/models/paged.dart';



class PagedList extends StatelessWidget {
  const PagedList({super.key, required this.pages});

  final List<PageGlyph> pages;

  @override
  Widget build(BuildContext context) {
    // We use SliverList so it integrates perfectly with the parent CustomScrollView
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final actualPageNumber = pages[index].page;
          final fontName = "QPCPage${actualPageNumber.toString().padLeft(3, '0')}";
          final cleanContent = pages[index].content.replaceAll('\n', ' ');

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Text(
                  cleanContent,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontFamily: fontName,
                    fontSize: 25,
                    height: 2.2,
                    color: Colors.black,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),


              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1.5)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "$actualPageNumber",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1)),
                  ],
                ),
              ),
            ],
          );
        },
        childCount: pages.length,
      ),
    );
  }
}