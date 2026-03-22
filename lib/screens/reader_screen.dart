import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';
import 'dart:math';

class ReaderScreen extends StatefulWidget {
  final Book book;

  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentPage;
  bool _showUI = false;
  bool _showSettings = false;
  double _fontSize = 16.0;
  double _lineHeight = 1.7;
  bool _nightMode = true;
  late AnimationController _uiController;
  late Animation<double> _uiAnim;

  // Simulated book content (in a real app this would parse epub/pdf)
  static const List<String> _sampleContent = [
    '''Chapter 1: The Foundation

In the beginning of software development, there was chaos. Systems were built without thought for the future, without care for the humans who would maintain them. Code was a mess of spaghetti, a tangle of dependencies, a nightmare of duplication.

Then came the pragmatic programmers. They saw the chaos and said: enough. They codified the wisdom of experienced developers into principles that could guide the next generation.

The first principle is simple: care about your craft. Why spend your life developing software unless you care about doing it well? This book is about programming as a craft: how to hone your skills, and how to apply them wisely.''',
    '''Chapter 1 (continued)

The word pragmatic comes from the Latin pragmaticus, meaning "skilled in business," which itself comes from the Greek word meaning "to do." A Pragmatic Programmer gets things done, but gets them done right.

What distinguishes Pragmatic Programmers? We feel it's an attitude, a style, a philosophy of approaching problems and their solutions. They think beyond the immediate problem, always trying to place it in its larger context, always trying to be aware of the bigger picture.

With that larger context, they are able to spot other options, discover alternative approaches, and transform raw feedback into actionable insights.''',
    '''Chapter 2: A Pragmatic Philosophy

This chapter talks about the attitude and approach of a Pragmatic Programmer.

The greatest of all weaknesses is the fear of appearing weak. Many developers are afraid to admit ignorance or mistakes. But the pragmatic programmer takes responsibility — and ownership — of everything they do.

If your code is a mess, own it. If a deadline was missed, own it. If a teammate's morale has tanked because of your attitude, own it.

The Cat Ate My Source Code: One of the cornerstones of the Pragmatic Philosophy is the idea of taking responsibility for yourself and your actions in terms of your career advancement, your learning and education, your project, and your day-to-day work.''',
    '''Chapter 2 (continued): Software Entropy

When disorder increases in software, programmers call it "software rot." Some folks blame this on physics and the second law of thermodynamics. Broken windows: don't leave "broken windows" (bad designs, wrong decisions, or poor code) unrepaired. Fix each one as soon as it is discovered. If there is insufficient time to fix it properly, then board it up.

"If you find yourself on a project where the code is pristinely beautiful — cleanly written, well designed, and elegant — you will likely take extra special care not to mess it up, just like the first person to step into a newly carpeted, immaculate room will be very reluctant to be the one who tracks in the mud."''',
    '''Chapter 3: The Basic Tools

Every craftsman starts their journey with a basic set of good-quality tools. A woodworker might need rules, gauges, a couple of saws, some good planes, fine chisels, drills and braces, mallets, and clamps. These tools will be lovingly chosen, will be built to last, will perform specific jobs with little overlap with the other tools, and are comfortable to use.

Tools amplify your talent. The better your tools, and the better you know how to use them, the more productive you can be. Start with a basic set of generally applicable tools. As you gain experience, and as you come across special requirements, you'll add to this basic set.

Always be on the lookout for better ways of doing things.''',
  ];

  List<String> get _pages => _sampleContent;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.book.currentPage > 0
        ? widget.book.currentPage.clamp(0, _pages.length - 1)
        : 0;
    _pageController = PageController(initialPage: _currentPage);
    _uiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _uiAnim = CurvedAnimation(parent: _uiController, curve: Curves.easeInOut);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _uiController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    context.read<LibraryService>().updateProgress(widget.book.id, _currentPage);
    super.dispose();
  }

  void _toggleUI() {
    setState(() => _showUI = !_showUI);
    if (_showUI) {
      _uiController.forward();
    } else {
      _uiController.reverse();
      _showSettings = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _nightMode ? const Color(0xFF0D1117) : const Color(0xFFF5F0E8),
      body: GestureDetector(
        onTap: _toggleUI,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                context.read<LibraryService>().updateProgress(widget.book.id, page);
              },
              itemBuilder: (context, index) => _buildPage(index),
            ),
            _buildTopBar(),
            _buildBottomBar(),
            if (_showSettings) _buildSettingsPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    final bg = _nightMode ? const Color(0xFF0D1117) : const Color(0xFFF5F0E8);
    final textColor = _nightMode ? const Color(0xFFD0D6E0) : const Color(0xFF1A1A1A);

    return Container(
      color: bg,
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 60,
        24,
        MediaQuery.of(context).padding.bottom + 80,
      ),
      child: SingleChildScrollView(
        child: Text(
          _pages[index],
          style: TextStyle(
            color: textColor,
            fontSize: _fontSize,
            height: _lineHeight,
            fontFamily: 'Georgia',
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return FadeTransition(
      opacity: _uiAnim,
      child: IgnorePointer(
        ignoring: !_showUI,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 8,
            16,
            12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                (_nightMode ? AppTheme.bgColor : const Color(0xFFF5F0E8))
                    .withOpacity(0.95),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppTheme.textPrimary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.book.author,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  final bm = Bookmark(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    page: _currentPage,
                    label: 'Page ${_currentPage + 1}',
                    createdAt: DateTime.now(),
                  );
                  context.read<LibraryService>().addBookmark(widget.book.id, bm);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Bookmark added'),
                      backgroundColor: AppTheme.cardColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppTheme.borderColor),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: const Icon(
                    Icons.bookmark_add_outlined,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _showSettings = !_showSettings),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
  return Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: FadeTransition(
      opacity: _uiAnim,
      child: IgnorePointer(
        ignoring: !_showUI,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                (_nightMode ? AppTheme.bgColor : const Color(0xFFF5F0E8))
                    .withOpacity(0.95),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous button
              GestureDetector(
                onTap: _currentPage > 0
                    ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _currentPage > 0
                          ? AppTheme.borderColor
                          : AppTheme.borderColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back_ios_rounded,
                          size: 14,
                          color: _currentPage > 0
                              ? AppTheme.textSecondary
                              : AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        'PREV',
                        style: TextStyle(
                          color: _currentPage > 0
                              ? AppTheme.textSecondary
                              : AppTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Page indicator
              Text(
                '${_currentPage + 1} / ${_pages.length}',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),

              // Next button
              GestureDetector(
                onTap: _currentPage < _pages.length - 1
                    ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _currentPage < _pages.length - 1
                        ? AppTheme.accentGreen.withOpacity(0.1)
                        : AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _currentPage < _pages.length - 1
                          ? AppTheme.accentGreen
                          : AppTheme.borderColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'NEXT',
                        style: TextStyle(
                          color: _currentPage < _pages.length - 1
                              ? AppTheme.accentGreen
                              : AppTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: _currentPage < _pages.length - 1
                              ? AppTheme.accentGreen
                              : AppTheme.textMuted),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildSettingsPanel() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      right: 16,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'READER SETTINGS',
                style: TextStyle(
                  color: AppTheme.accentGreen,
                  fontSize: 9,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Font Size',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _fontSize = max(12, _fontSize - 1)),
                    child: _SettingBtn(label: 'A', small: true),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        thumbColor: AppTheme.accentGreen,
                        activeTrackColor: AppTheme.accentGreen,
                        inactiveTrackColor: AppTheme.borderColor,
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: _fontSize,
                        min: 12,
                        max: 24,
                        onChanged: (v) => setState(() => _fontSize = v),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _fontSize = min(24, _fontSize + 1)),
                    child: _SettingBtn(label: 'A', small: false),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Theme',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _ThemeOption(
                    label: 'Dark',
                    selected: _nightMode,
                    bg: const Color(0xFF0D1117),
                    textColor: const Color(0xFFD0D6E0),
                    onTap: () => setState(() => _nightMode = true),
                  ),
                  const SizedBox(width: 8),
                  _ThemeOption(
                    label: 'Sepia',
                    selected: !_nightMode,
                    bg: const Color(0xFFF5F0E8),
                    textColor: const Color(0xFF1A1A1A),
                    onTap: () => setState(() => _nightMode = false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingBtn extends StatelessWidget {
  final String label;
  final bool small;
  const _SettingBtn({required this.label, required this.small});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: small ? 11 : 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final bool selected;
  final Color bg;
  final Color textColor;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.selected,
    required this.bg,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected ? AppTheme.accentGreen : AppTheme.borderColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
