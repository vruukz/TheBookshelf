import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';
import '../models/book.dart';
import '../widgets/book_card.dart';
import '../widgets/stats_bar.dart';
import '../widgets/currently_reading_card.dart';
import 'library_screen.dart';
import 'book_detail_screen.dart';
import 'add_book_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = context.read<LibraryService>();
      service.loadLibrary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _HomeTab(),
          LibraryScreen(),
          StatsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? _buildFAB()
          : null,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: const Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: NavigationBar(
        backgroundColor: AppTheme.surfaceColor,
        indicatorColor: AppTheme.accentGreen.withOpacity(0.15),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: AppTheme.textMuted),
            selectedIcon: Icon(Icons.home_rounded, color: AppTheme.accentGreen),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined, color: AppTheme.textMuted),
            selectedIcon: Icon(Icons.menu_book_rounded, color: AppTheme.accentGreen),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined, color: AppTheme.textMuted),
            selectedIcon: Icon(Icons.bar_chart_rounded, color: AppTheme.accentGreen),
            label: 'Stats',
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      backgroundColor: AppTheme.accentGreen,
      foregroundColor: AppTheme.bgColor,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddBookScreen()),
      ),
      child: const Icon(Icons.add_rounded),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryService>(
      builder: (context, library, _) {
        return CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(child: _buildGreeting(context, library)),
            SliverToBoxAdapter(child: _buildStatsRow(library)),
            if (library.currentlyReading.isNotEmpty) ...[
              _buildSectionHeader(context, '▶ CURRENTLY READING',
                  '${library.currentlyReading.length} books'),
              SliverToBoxAdapter(child: _buildCurrentlyReading(context, library)),
            ],
            _buildSectionHeader(context, '◎ RECENT ADDITIONS',
                'all ${library.totalBooks}'),
            _buildRecentGrid(context, library),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.bgColor,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.accentGreen),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'BV',
              style: TextStyle(
                color: AppTheme.accentGreen,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'BookVault',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context, LibraryService library) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, reader.',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: library.booksReading > 0
                      ? '${library.booksReading} book${library.booksReading > 1 ? 's' : ''} in progress'
                      : 'Your library awaits',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                if (library.booksReading > 0)
                  const TextSpan(
                    text: '.',
                    style: TextStyle(
                      color: AppTheme.accentGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(LibraryService library) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: [
          _StatChip(
            label: 'TOTAL',
            value: library.totalBooks.toString(),
            icon: Icons.auto_stories_outlined,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'FINISHED',
            value: library.booksRead.toString(),
            icon: Icons.check_circle_outline_rounded,
            accent: true,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'HOURS READ',
            value: (library.totalReadingMinutes ~/ 60).toString(),
            icon: Icons.timer_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentlyReading(BuildContext context, LibraryService library) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        itemCount: library.currentlyReading.length,
        itemBuilder: (context, index) {
          final book = library.currentlyReading[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CurrentlyReadingCard(
              book: book,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookDetailScreen(book: book),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  SliverPadding _buildSectionHeader(BuildContext context, String title, String sub) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.accentGreen,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            Text(
              sub.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildRecentGrid(BuildContext context, LibraryService library) {
    final books = library.recentlyAdded.take(6).toList();
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.6,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final book = books[index];
            return BookCard(
              book: book,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookDetailScreen(book: book),
                ),
              ),
            );
          },
          childCount: books.length,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool accent;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent ? AppTheme.accentGreen.withOpacity(0.08) : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: accent ? AppTheme.accentGreen.withOpacity(0.3) : AppTheme.borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: accent ? AppTheme.accentGreen : AppTheme.textMuted,
                size: 16),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: accent ? AppTheme.accentGreen : AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
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
