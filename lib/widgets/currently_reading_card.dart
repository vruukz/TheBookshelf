import 'package:flutter/material.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';

class CurrentlyReadingCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const CurrentlyReadingCard({
    super.key,
    required this.book,
    required this.onTap,
  });

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
        width: 260,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 68,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  book.title.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: book.progress,
                      backgroundColor: AppTheme.borderColor,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'p.${book.currentPage}',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        book.progressPercent,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
