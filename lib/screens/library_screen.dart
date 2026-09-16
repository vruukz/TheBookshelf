import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';
import '../models/book.dart';
import '../widgets/book_list_tile.dart';
import 'book_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isGridView = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryService>(
      builder: (context, library, _) {
        return Scaffold(
          backgroundColor: AppTheme.bgColor,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, library),
              _buildFilterBar(context, library),
              _buildBookList(context, library),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, LibraryService library) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.bgColor,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Search title or author...',
                hintStyle: TextStyle(color: AppTheme.textMuted),
                border: InputBorder.none,
              ),
              onChanged: library.setSearchQuery,
            )
          : const Text(
              'Library',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close_rounded : Icons.search_rounded,
            color: AppTheme.textSecondary,
          ),
          onPressed: () {
            setState(() => _isSearching = !_isSearching);
            if (!_isSearching) {
              _searchController.clear();
              library.setSearchQuery('');
            }
          },
        ),
        IconButton(
          icon: Icon(
            _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
            color: AppTheme.textSecondary,
          ),
          onPressed: () => setState(() => _isGridView = !_isGridView),
        ),
        _SortMenu(library: library),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.borderColor),
      ),
    );
  }

  SliverToBoxAdapter _buildFilterBar(BuildContext context, LibraryService library) {
    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            _FilterChip(
              label: 'ALL',
              selected: library.filterStatus == null,
              onTap: () => library.setFilterStatus(null),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'READING',
              selected: library.filterStatus == ReadingStatus.reading,
              onTap: () => library.setFilterStatus(ReadingStatus.reading),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'FINISHED',
              selected: library.filterStatus == ReadingStatus.finished,
              onTap: () => library.setFilterStatus(ReadingStatus.finished),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'UNREAD',
              selected: library.filterStatus == ReadingStatus.unread,
              onTap: () => library.setFilterStatus(ReadingStatus.unread),
            ),
            const SizedBox(width: 8),
            Container(width: 1, height: 24, color: AppTheme.borderColor),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'EPUB',
              selected: library.filterFormat == BookFormat.epub,
              onTap: () => library.setFilterFormat(
                library.filterFormat == BookFormat.epub ? null : BookFormat.epub,
              ),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'PDF',
              selected: library.filterFormat == BookFormat.pdf,
              onTap: () => library.setFilterFormat(
                library.filterFormat == BookFormat.pdf ? null : BookFormat.pdf,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookList(BuildContext context, LibraryService library) {
    final books = library.filteredBooks;

    if (books.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_stories_outlined,
                  size: 48, color: AppTheme.textMuted),
              const SizedBox(height: 16),
              const Text(
                'No books found',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try adjusting your filters',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_isGridView) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _GridBookCard(
              book: books[index],
              onTap: () => _openBook(context, books[index]),
            ),
            childCount: books.length,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < books.length) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BookListTile(
                  book: books[index],
                  onTap: () => _openBook(context, books[index]),
                ),
              );
            }
            return null;
          },
          childCount: books.length,
        ),
      ),
    );
  }

  void _openBook(BuildContext context, Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accentGreen.withOpacity(0.12)
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? AppTheme.accentGreen : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.accentGreen : AppTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  final LibraryService library;
  const _SortMenu({required this.library});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort_rounded, color: AppTheme.textSecondary),
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      onSelected: library.setSortBy,
      itemBuilder: (_) => [
        _sortItem('recent', 'Recently Read', library),
        _sortItem('title', 'Title A–Z', library),
        _sortItem('author', 'Author A–Z', library),
        _sortItem('progress', 'Progress', library),
      ],
    );
  }

  PopupMenuItem<String> _sortItem(
      String value, String label, LibraryService library) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            library.sortBy == value
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            color: library.sortBy == value
                ? AppTheme.accentGreen
                : AppTheme.textMuted,
            size: 16,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: library.sortBy == value
                  ? AppTheme.accentGreen
                  : AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _GridBookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _bookColor(book).withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                ),
                child: Center(
                  child: Text(
                    book.title.substring(0, book.title.length.clamp(0, 2)).toUpperCase(),
                    style: TextStyle(
                      color: _bookColor(book),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                  if (book.status == ReadingStatus.reading) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: book.progress,
                        backgroundColor: AppTheme.borderColor,
                        valueColor: AlwaysStoppedAnimation(AppTheme.accentGreen),
                        minHeight: 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _bookColor(Book book) {
    final colors = [
      AppTheme.accentGreen,
      const Color(0xFF60A5FA),
      const Color(0xFFF59E0B),
      const Color(0xFFA78BFA),
      const Color(0xFFF87171),
    ];
    return colors[book.id.hashCode % colors.length];
  }
}
