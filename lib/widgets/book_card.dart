import 'package:flutter/material.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookCard({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _bookColor(book);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Center(
                child: Text(
                  book.title.isNotEmpty ? book.title[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
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
                  const Spacer(),
                  if (book.status == ReadingStatus.reading)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: LinearProgressIndicator(
                        value: book.progress,
                        backgroundColor: AppTheme.borderColor,
                        valueColor: AlwaysStoppedAnimation(AppTheme.accentGreen),
                        minHeight: 2,
                      ),
                    )
                  else
                    _StatusDot(status: book.status),
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

class _StatusDot extends StatelessWidget {
  final ReadingStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      ReadingStatus.finished => (AppTheme.accentGreen, '✓'),
      ReadingStatus.unread => (AppTheme.textMuted, '○'),
      ReadingStatus.reading => (const Color(0xFFF59E0B), '◑'),
    };
    return Text(label, style: TextStyle(color: color, fontSize: 12));
  }
}
