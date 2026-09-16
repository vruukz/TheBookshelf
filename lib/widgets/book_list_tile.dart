import 'package:flutter/material.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';

class BookListTile extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookListTile({super.key, required this.book, required this.onTap});

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

  @override
  Widget build(BuildContext context) {
    final color = _bookColor(book);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 58,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title.isNotEmpty ? book.title[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      border: Border.all(color: color.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      book.formatExtension,
                      style: TextStyle(
                        color: color.withOpacity(0.7),
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book.author,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  if (book.status == ReadingStatus.reading) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: book.progress,
                              backgroundColor: AppTheme.borderColor,
                              valueColor: AlwaysStoppedAnimation(
                                  AppTheme.accentGreen),
                              minHeight: 3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          book.progressPercent,
                          style: TextStyle(
                            color: AppTheme.accentGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            _StatusIcon(status: book.status),
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final ReadingStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      ReadingStatus.finished => (Icons.check_circle_rounded, AppTheme.accentGreen),
      ReadingStatus.reading => (Icons.menu_book_rounded, const Color(0xFFF59E0B)),
      ReadingStatus.unread => (Icons.circle_outlined, AppTheme.textMuted),
    };
    return Icon(icon, color: color, size: 18);
  }
}
