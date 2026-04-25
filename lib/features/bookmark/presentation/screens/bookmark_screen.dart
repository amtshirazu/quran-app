import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ENUM FOR TABS
enum BookmarkTab { all, verses, pages }

class BookmarkScreen extends ConsumerStatefulWidget {
  const BookmarkScreen({super.key});

  @override
  ConsumerState<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends ConsumerState<BookmarkScreen> {
  BookmarkTab activeTab = BookmarkTab.all;

  // TODO: Replace with Riverpod providers
  final List<Map<String, dynamic>> verseBookmarks = [];
  final List<Map<String, dynamic>> pageBookmarks = [];

  int get totalCount {
    switch (activeTab) {
      case BookmarkTab.all:
        return verseBookmarks.length + pageBookmarks.length;
      case BookmarkTab.verses:
        return verseBookmarks.length;
      case BookmarkTab.pages:
        return pageBookmarks.length;
    }
  }

  void handleDeleteAll() {
    String message = "";

    if (activeTab == BookmarkTab.all) {
      message = "Delete all bookmarks?";
    } else if (activeTab == BookmarkTab.verses) {
      message = "Delete all verse bookmarks?";
    } else {
      message = "Delete all page bookmarks?";
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: delete logic
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8E1), Colors.white],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFD97706),
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bookmarks",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    "$totalCount saved",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              if (totalCount > 0)
                IconButton(
                  onPressed: handleDeleteAll,
                  icon: const Icon(Icons.delete, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTabs(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _tabButton("All", BookmarkTab.all),
        _tabButton("Verses", BookmarkTab.verses),
        _tabButton("Pages", BookmarkTab.pages),
      ],
    );
  }

  Widget _tabButton(String text, BookmarkTab tab) {
    final isActive = activeTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => activeTab = tab),
        child: Container(
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: isActive ? Colors.orange : Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (activeTab == BookmarkTab.all) {
      if (verseBookmarks.isEmpty && pageBookmarks.isEmpty) {
        return _emptyState();
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (verseBookmarks.isNotEmpty) ...[
            const Text("Verse Bookmarks"),
            ...verseBookmarks.map((b) => VerseBookmarkCard(b)),
          ],
          if (pageBookmarks.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text("Page Bookmarks"),
            ...pageBookmarks.map((b) => PageBookmarkCard(b)),
          ],
        ],
      );
    }

    if (activeTab == BookmarkTab.verses) {
      if (verseBookmarks.isEmpty) return _emptyState();

      return ListView(
        padding: const EdgeInsets.all(16),
        children: verseBookmarks.map((b) => VerseBookmarkCard(b)).toList(),
      );
    }

    if (pageBookmarks.isEmpty) return _emptyState();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: pageBookmarks.map((b) => PageBookmarkCard(b)).toList(),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.bookmark, size: 60, color: Colors.orange),
          SizedBox(height: 12),
          Text("No Bookmarks Yet"),
        ],
      ),
    );
  }
}

// ------------------ VERSE CARD ------------------

class VerseBookmarkCard extends StatelessWidget {
  final Map<String, dynamic> bookmark;

  const VerseBookmarkCard(this.bookmark, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Surah ${bookmark['surah_id']} : ${bookmark['ayah_number']}",
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
              ],
            ),
            const SizedBox(height: 8),
            Text(bookmark['note'] ?? ""),
            TextButton(onPressed: () {}, child: const Text("Read Surah")),
          ],
        ),
      ),
    );
  }
}

// ------------------ PAGE CARD ------------------

class PageBookmarkCard extends StatelessWidget {
  final Map<String, dynamic> bookmark;

  const PageBookmarkCard(this.bookmark, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Page ${bookmark['page']}"),
                IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
              ],
            ),
            const SizedBox(height: 8),
            Text(bookmark['note'] ?? ""),
            TextButton(onPressed: () {}, child: const Text("Open Page")),
          ],
        ),
      ),
    );
  }
}
