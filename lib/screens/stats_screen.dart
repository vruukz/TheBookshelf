import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/library_service.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryService>(
      builder: (context, library, _) {
        return Scaffold(
          backgroundColor: AppTheme.bgColor,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildOverview(library),
                    const SizedBox(height: 24),
                    _buildFormatBreakdown(library),
                    const SizedBox(height: 24),
                    _buildStatusBreakdown(library),
                    const SizedBox(height: 24),
                    _buildTopAuthors(library),
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

  SliverAppBar _buildAppBar() {
    return const SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.bgColor,
      title: Text(
        'Statistics',
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(color: AppTheme.borderColor, height: 1),
      ),
    );
  }

  Widget _buildOverview(LibraryService library) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OVERVIEW',
          style: TextStyle(
            color: AppTheme.accentGreen,
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _BigStatCard(
              value: library.totalBooks.toString(),
              label: 'Total Books',
              icon: Icons.auto_stories_outlined,
            ),
            const SizedBox(width: 10),
            _BigStatCard(
              value: library.booksRead.toString(),
              label: 'Completed',
              icon: Icons.check_circle_outline_rounded,
              accent: true,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _BigStatCard(
              value: library.booksReading.toString(),
              label: 'In Progress',
              icon: Icons.auto_fix_high_outlined,
            ),
            const SizedBox(width: 10),
            _BigStatCard(
              value: '${(library.totalReadingMinutes / 60).toStringAsFixed(1)}h',
              label: 'Hours Read',
              icon: Icons.timer_outlined,
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (library.totalBooks > 0)
          Container(
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
                      'OVERALL COMPLETION',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 9,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(library.booksRead / library.totalBooks * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: library.totalBooks > 0
                        ? library.booksRead / library.totalBooks
                        : 0,
                    backgroundColor: AppTheme.borderColor,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.accentGreen),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFormatBreakdown(LibraryService library) {
    final formats = <BookFormat, int>{};
    for (final book in library.allBooks) {
      formats[book.format] = (formats[book.format] ?? 0) + 1;
    }

    if (formats.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BY FORMAT',
          style: TextStyle(
            color: AppTheme.accentGreen,
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: formats.entries.map((e) {
              final pct = library.totalBooks > 0 ? e.value / library.totalBooks : 0.0;
              final colors = {
                BookFormat.epub: AppTheme.accentGreen,
                BookFormat.pdf: const Color(0xFF60A5FA),
                BookFormat.txt: const Color(0xFFF59E0B),
                BookFormat.mobi: const Color(0xFFA78BFA),
              };
              final color = colors[e.key] ?? AppTheme.accentGreen;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.key.name.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${e.value} book${e.value != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: pct.toDouble(),
                        backgroundColor: AppTheme.borderColor,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBreakdown(LibraryService library) {
    final unread = library.allBooks
        .where((b) => b.status == ReadingStatus.unread)
        .length;
    final reading = library.booksReading;
    final finished = library.booksRead;
    final total = library.totalBooks;

    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'READING STATUS',
          style: TextStyle(
            color: AppTheme.accentGreen,
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            children: [
              _StatusRing(
                unread: unread,
                reading: reading,
                finished: finished,
                total: total,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _StatusRow(
                      color: AppTheme.textMuted,
                      label: 'Unread',
                      count: unread,
                      total: total,
                    ),
                    const SizedBox(height: 8),
                    _StatusRow(
                      color: const Color(0xFFF59E0B),
                      label: 'Reading',
                      count: reading,
                      total: total,
                    ),
                    const SizedBox(height: 8),
                    _StatusRow(
                      color: AppTheme.accentGreen,
                      label: 'Finished',
                      count: finished,
                      total: total,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopAuthors(LibraryService library) {
    final authors = <String, int>{};
    for (final book in library.allBooks) {
      authors[book.author] = (authors[book.author] ?? 0) + 1;
    }

    final sorted = authors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TOP AUTHORS',
          style: TextStyle(
            color: AppTheme.accentGreen,
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...sorted.take(5).map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      e.key[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.key,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  '${e.value} book${e.value != 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool accent;

  const _BigStatCard({
    required this.value,
    required this.label,
    required this.icon,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: accent ? AppTheme.accentGreen.withOpacity(0.07) : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: accent ? AppTheme.accentGreen.withOpacity(0.3) : AppTheme.borderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: accent ? AppTheme.accentGreen : AppTheme.textMuted,
                size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: accent ? AppTheme.accentGreen : AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRing extends StatelessWidget {
  final int unread, reading, finished, total;
  const _StatusRing({
    required this.unread,
    required this.reading,
    required this.finished,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: CustomPaint(
        painter: _RingPainter(
          unread: unread / total,
          reading: reading / total,
          finished: finished / total,
        ),
        child: Center(
          child: Text(
            '$total',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double unread, reading, finished;
  _RingPainter({required this.unread, required this.reading, required this.finished});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 8.0;
    const startAngle = -1.5708; // -pi/2

    final bgPaint = Paint()
      ..color = AppTheme.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final colors = [
      (AppTheme.textMuted, unread),
      (const Color(0xFFF59E0B), reading),
      (AppTheme.accentGreen, finished),
    ];

    double currentAngle = startAngle;
    for (final (color, value) in colors) {
      if (value <= 0) continue;
      final sweepAngle = value * 6.2832;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle - 0.1,
        false,
        paint,
      );
      currentAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => true;
}

class _StatusRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final int total;

  const _StatusRow({
    required this.color,
    required this.label,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
