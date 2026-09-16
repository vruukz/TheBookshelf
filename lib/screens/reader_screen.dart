import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import '../models/book.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';
import 'package:flutter/foundation.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;
  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with SingleTickerProviderStateMixin {
  // shared
  bool _showUI = false;
  bool _showSettings = false;
  double _fontSize = 16.0;
  bool _nightMode = true;
  late AnimationController _uiController;
  late Animation<double> _uiAnim;

  // TXT
  late PageController _pageController;
  int _currentPage = 0;
  List<String> _pages = ['Loading...'];

  // EPUB
  EpubController? _epubController;

  // PDF
  int _pdfCurrentPage = 0;
  int _pdfTotalPages = 0;
  PDFViewController? _pdfViewController;

  String get _ext =>
      widget.book.filePath.split('.').last.toLowerCase();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _uiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _uiAnim = CurvedAnimation(parent: _uiController, curve: Curves.easeInOut);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (_ext == 'epub') {
      _epubController = EpubController(
        document: EpubDocument.openFile(File(widget.book.filePath)),
      );
    } else if (_ext == 'txt') {
      _loadTxt();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _epubController?.dispose();
    _uiController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    context.read<LibraryService>().updateProgress(
          widget.book.id,
          _ext == 'pdf' ? _pdfCurrentPage : _currentPage,
        );
    super.dispose();
  }

  Future<void> _loadTxt() async {
    try {
      final file = File(widget.book.filePath);
      if (!await file.exists()) {
        setState(() => _pages = ['File not found:\n${widget.book.filePath}']);
        return;
      }
      final content = await file.readAsString();
      final chunks = <String>[];
      int i = 0;
      while (i < content.length) {
        int end = i + 1500;
        if (end < content.length) {
          final breakAt = content.lastIndexOf('\n\n', end);
          if (breakAt > i) end = breakAt;
        } else {
          end = content.length;
        }
        chunks.add(content.substring(i, end).trim());
        i = end;
      }
      setState(() => _pages = chunks.isEmpty ? ['Empty file'] : chunks);
    } catch (e) {
      setState(() => _pages = ['Error loading file:\n$e']);
    }
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
      backgroundColor:
          _nightMode ? const Color(0xFF0D1117) : const Color(0xFFF5F0E8),
      body: GestureDetector(
        onTap: _toggleUI,
        child: Stack(
          children: [
            _buildReader(),
            _buildTopBar(),
            if (_ext != 'epub') _buildBottomBar(),
            if (_showSettings) _buildSettingsPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildReader() {
    switch (_ext) {
      case 'epub':
        return EpubView(
          controller: _epubController!,
          builders: EpubViewBuilders<DefaultBuilderOptions>(
            options: DefaultBuilderOptions(
              textStyle: TextStyle(
                fontSize: _fontSize,
                height: 1.7,
                color: _nightMode
                    ? const Color(0xFFD0D6E0)
                    : const Color(0xFF1A1A1A),
              ),
            ),
            chapterDividerBuilder: (_) => const Divider(
              color: AppTheme.borderColor,
              height: 32,
            ),
          ),
        );

      case 'pdf':
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    return PDFView(
      filePath: widget.book.filePath,
      enableSwipe: true,
      swipeHorizontal: true,
      nightMode: _nightMode,
      autoSpacing: true,
      pageFling: true,
      onRender: (pages) => setState(() => _pdfTotalPages = pages ?? 0),
      onViewCreated: (controller) =>
          setState(() => _pdfViewController = controller),
      onPageChanged: (page, total) => setState(() {
        _pdfCurrentPage = page ?? 0;
        _pdfTotalPages = total ?? 0;
      }),
      onError: (e) => debugPrint('PDF error: $e'),
    );
  } else {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf_outlined,
              color: AppTheme.textMuted, size: 48),
          const SizedBox(height: 16),
          const Text(
            'PDF reading is only\nsupported on Android',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'Run the app on your phone\nto read this file',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

      default: // TXT
        return PageView.builder(
          controller: _pageController,
          itemCount: _pages.length,
          onPageChanged: (page) {
            setState(() => _currentPage = page);
            context
                .read<LibraryService>()
                .updateProgress(widget.book.id, page);
          },
          itemBuilder: (context, index) => Container(
            color: _nightMode
                ? const Color(0xFF0D1117)
                : const Color(0xFFF5F0E8),
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
                  color: _nightMode
                      ? const Color(0xFFD0D6E0)
                      : const Color(0xFF1A1A1A),
                  fontSize: _fontSize,
                  height: 1.7,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        );
    }
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: AppTheme.textPrimary, size: 18),
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
                          color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  final bm = Bookmark(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    page: _ext == 'pdf' ? _pdfCurrentPage : _currentPage,
                    label:
                        'Page ${(_ext == 'pdf' ? _pdfCurrentPage : _currentPage) + 1}',
                    createdAt: DateTime.now(),
                  );
                  context
                      .read<LibraryService>()
                      .addBookmark(widget.book.id, bm);
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: const Icon(Icons.bookmark_add_outlined,
                      color: AppTheme.textSecondary, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () =>
                    setState(() => _showSettings = !_showSettings),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: const Icon(Icons.tune_rounded,
                      color: AppTheme.textSecondary, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final currentPage = _ext == 'pdf' ? _pdfCurrentPage : _currentPage;
    final totalPages =
        _ext == 'pdf' ? _pdfTotalPages : _pages.length;

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
                GestureDetector(
                  onTap: currentPage > 0
                      ? () {
                          if (_ext == 'pdf') {
                            _pdfViewController
                                ?.setPage(_pdfCurrentPage - 1);
                          } else {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: currentPage > 0
                            ? AppTheme.borderColor
                            : AppTheme.borderColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_rounded,
                            size: 14,
                            color: currentPage > 0
                                ? AppTheme.textSecondary
                                : AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'PREV',
                          style: TextStyle(
                            color: currentPage > 0
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
                Text(
                  '${currentPage + 1} / $totalPages',
                  style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                      letterSpacing: 0.5),
                ),
                GestureDetector(
                  onTap: currentPage < totalPages - 1
                      ? () {
                          if (_ext == 'pdf') {
                            _pdfViewController
                                ?.setPage(_pdfCurrentPage + 1);
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: currentPage < totalPages - 1
                          ? AppTheme.accentGreen.withOpacity(0.1)
                          : AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: currentPage < totalPages - 1
                            ? AppTheme.accentGreen
                            : AppTheme.borderColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'NEXT',
                          style: TextStyle(
                            color: currentPage < totalPages - 1
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
                            color: currentPage < totalPages - 1
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
              Text(
                'READER SETTINGS',
                style: TextStyle(
                  color: AppTheme.accentGreen,
                  fontSize: 9,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Font Size',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() =>
                        _fontSize = _fontSize > 12 ? _fontSize - 1 : 12),
                    child: const _SettingBtn(label: 'A', small: true),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
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
                    onTap: () => setState(() =>
                        _fontSize = _fontSize < 24 ? _fontSize + 1 : 24),
                    child: const _SettingBtn(label: 'A', small: false),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Theme',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
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