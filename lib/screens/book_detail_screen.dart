import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';
import 'reader_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryService>(
      builder: (context, library, _) {
        final currentBook =
            library.allBooks.firstWhere((b) => b.id == book.id, orElse: () => book);

        return Scaffold(
          backgroundColor: AppTheme.bgColor,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, currentBook, library),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(currentBook),
                    const SizedBox(height: 24),
                    _buildProgressSection(currentBook),
                    const SizedBox(height: 24),
                    _buildMetaInfo(currentBook),
                    const SizedBox(height: 24),
                    if (currentBook.description != null) ...[
                      _buildDescription(currentBook),
                      const SizedBox(height: 24),
                    ],
                    _buildTags(currentBook),
                    const SizedBox(height: 24),
                    if (currentBook.bookmarks.isNotEmpty) ...[
                      _buildBookmarks(context, currentBook, library),
                      const SizedBox(height: 24),
                    ],
                    _buildActionButtons(context, currentBook),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, Book book, LibraryService library) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.bgColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
          color: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppTheme.borderColor),
          ),
          onSelected: (value) async {
            if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppTheme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppTheme.borderColor),
                  ),
                  title: const Text('Remove Book',
                      style: TextStyle(color: AppTheme.textPrimary)),
                  content: Text(
                    'Remove "${book.title}" from your library?',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel',
                          style: TextStyle(color: AppTheme.textMuted)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Remove',
                          style: TextStyle(color: Color(0xFFF87171))),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await library.removeBook(book.id);
                if (context.mounted) Navigator.pop(context);
              }
            } else if (value == 'mark_finished') {
              final updated = book.copyWith(
                status: ReadingStatus.finished,
                currentPage: book.totalPages,
              );
              await library.updateBook(updated);
            } else if (value == 'mark_unread') {
              final updated = book.copyWith(
                status: ReadingStatus.unread,
                currentPage: 0,
              );
              await library.updateBook(updated);
            }
          },
          itemBuilder: (_) => [
            if (book.status != ReadingStatus.finished)
              PopupMenuItem(
                value: 'mark_finished',
                child: Row(children: [
                  Icon(Icons.check_circle_outline_rounded,
                      color: AppTheme.accentGreen, size: 16),
                  SizedBox(width: 10),
                  Text('Mark as Finished',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ]),
              ),
            if (book.status != ReadingStatus.unread)
              const PopupMenuItem(
                value: 'mark_unread',
                child: Row(children: [
                  Icon(Icons.refresh_rounded,
                      color: AppTheme.textMuted, size: 16),
                  SizedBox(width: 10),
                  Text('Mark as Unread',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ]),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFF87171), size: 16),
                SizedBox(width: 10),
                Text('Remove',
                    style: TextStyle(color: Color(0xFFF87171))),
              ]),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.borderColor),
      ),
    );
  }

  Widget _buildHeader(Book book) {
    final color = _bookColor(book);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 110,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                book.title
                    .split(' ')
                    .take(2)
                    .map((w) => w.isNotEmpty ? w[0] : '')
                    .join()
                    .toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: color.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  book.formatExtension,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusBadge(status: book.status),
              const SizedBox(height: 8),
              Text(
                book.title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                book.author,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(Book book) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PROGRESS',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                book.status == ReadingStatus.unread
                    ? 'NOT STARTED'
                    : book.status == ReadingStatus.finished
                        ? '✓ COMPLETE'
                        : '${book.progressPercent} — p.${book.currentPage}/${book.totalPages}',
                style: TextStyle(
                  color: book.status == ReadingStatus.finished
                      ? AppTheme.accentGreen
                      : AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: book.progress,
              backgroundColor: AppTheme.borderColor,
              valueColor: AlwaysStoppedAnimation(AppTheme.accentGreen),
              minHeight: 6,
            ),
          ),
          if (book.readingTimeMinutes > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.timer_outlined,
                    size: 13, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                Text(
                  '${book.readingTimeMinutes} minutes read',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaInfo(Book book) {
    return Row(
      children: [
        _MetaChip(
          label: 'FORMAT',
          value: book.formatExtension,
          icon: Icons.description_outlined,
        ),
        const SizedBox(width: 10),
        _MetaChip(
          label: 'PAGES',
          value: book.totalPages > 0 ? '${book.totalPages}' : '—',
          icon: Icons.auto_stories_outlined,
        ),
        const SizedBox(width: 10),
        _MetaChip(
          label: 'ADDED',
          value: _formatDate(book.addedAt),
          icon: Icons.calendar_today_outlined,
        ),
      ],
    );
  }

  Widget _buildDescription(Book book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DESCRIPTION',
          style: TextStyle(
            color: AppTheme.accentGreen,
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          book.description!,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _buildTags(Book book) {
    if (book.tags.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: book.tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.accentGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.accentGreen.withOpacity(0.2)),
        ),
        child: Text(
          '# $tag',
          style: TextStyle(
            color: AppTheme.accentGreen,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildBookmarks(
      BuildContext context, Book book, LibraryService library) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BOOKMARKS',
          style: TextStyle(
            color: AppTheme.accentGreen,
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ...book.bookmarks.map((bm) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.bookmark_rounded,
                    color: AppTheme.accentGreen, size: 14),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    bm.label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  'p.${bm.page}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => library.removeBookmark(book.id, bm.id),
                  child: const Icon(Icons.close_rounded,
                      color: AppTheme.textMuted, size: 14),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Book book) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: AppTheme.bgColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReaderScreen(book: book),
              ),
            ),
            icon: const Icon(Icons.menu_book_rounded, size: 18),
            label: Text(
              book.status == ReadingStatus.unread ? 'START READING' : 'CONTINUE READING',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _StatusBadge extends StatelessWidget {
  final ReadingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ReadingStatus.reading => ('READING', AppTheme.accentGreen),
      ReadingStatus.finished => ('FINISHED', const Color(0xFF60A5FA)),
      ReadingStatus.unread => ('UNREAD', AppTheme.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetaChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 13, color: AppTheme.textMuted),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 9,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
