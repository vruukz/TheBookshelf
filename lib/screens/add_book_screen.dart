import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../services/library_service.dart';
import '../theme/app_theme.dart';


class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descController = TextEditingController();
  final _pagesController = TextEditingController();
  final _tagsController = TextEditingController();
  BookFormat _format = BookFormat.epub;
  String _filePath = '';
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descController.dispose();
    _pagesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['epub', 'pdf', 'txt', 'mobi'],
  );

  if (result != null && result.files.single.path != null) {
    final file = result.files.single;
    final path = file.path!;
    final ext = file.extension?.toLowerCase() ?? 'epub';

    final fmt = switch (ext) {
      'pdf'  => BookFormat.pdf,
      'txt'  => BookFormat.txt,
      'mobi' => BookFormat.mobi,
      _      => BookFormat.epub,
    };

    setState(() {
      _filePath = path;
      _format = fmt;
      if (_titleController.text.isEmpty) {
        _titleController.text = file.name
            .replaceAll(RegExp(r'\.(epub|pdf|txt|mobi)$', caseSensitive: false), '')
            .replaceAll('_', ' ')
            .replaceAll('-', ' ');
      }
    });
  }
}

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      _showError('Title is required');
      return;
    }
    if (_authorController.text.trim().isEmpty) {
      _showError('Author is required');
      return;
    }

    setState(() => _saving = true);

    final book = Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      filePath: _filePath.isNotEmpty
          ? _filePath
          : '/storage/books/${_titleController.text}.${_format.name}',
      format: _format,
      totalPages: int.tryParse(_pagesController.text) ?? 0,
      addedAt: DateTime.now(),
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : null,
      tags: _tagsController.text.isNotEmpty
          ? _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
          : [],
    );

    await context.read<LibraryService>().addBook(book);

    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFF87171).withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AppTheme.bgColor,
        title: const Text(
          'Add Book',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _saving ? null : _save,
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                foregroundColor: AppTheme.bgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.bgColor,
                      ),
                    )
                  : const Text(
                      'SAVE',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.borderColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildFilePicker(),
          const SizedBox(height: 24),
          _buildSectionLabel('BOOK INFO'),
          const SizedBox(height: 12),
          _buildField(
            controller: _titleController,
            label: 'Title',
            hint: 'The Pragmatic Programmer',
            required: true,
          ),
          const SizedBox(height: 12),
          _buildField(
            controller: _authorController,
            label: 'Author',
            hint: 'David Thomas, Andrew Hunt',
            required: true,
          ),
          const SizedBox(height: 12),
          _buildField(
            controller: _pagesController,
            label: 'Total Pages',
            hint: '352',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          _buildSectionLabel('FORMAT'),
          const SizedBox(height: 12),
          _buildFormatSelector(),
          const SizedBox(height: 24),
          _buildSectionLabel('OPTIONAL'),
          const SizedBox(height: 12),
          _buildField(
            controller: _descController,
            label: 'Description',
            hint: 'A brief description...',
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _buildField(
            controller: _tagsController,
            label: 'Tags (comma-separated)',
            hint: 'programming, software engineering',
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildFilePicker() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.accentGreen.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.accentGreen.withOpacity(0.3),
            style: _filePath.isEmpty ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _filePath.isEmpty
                  ? Icons.upload_file_rounded
                  : Icons.check_circle_outline_rounded,
              color: AppTheme.accentGreen,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _filePath.isEmpty ? 'TAP TO SELECT FILE' : 'FILE SELECTED',
              style: TextStyle(
                color: AppTheme.accentGreen,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _filePath.isEmpty
                  ? 'EPUB, PDF, TXT, MOBI'
                  : _filePath.split('/').last,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: AppTheme.accentGreen,
        fontSize: 10,
        letterSpacing: 2,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required)
              Text(' *', style: TextStyle(color: AppTheme.accentGreen, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
            filled: true,
            fillColor: AppTheme.cardColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppTheme.accentGreen),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSelector() {
    return Row(
      children: BookFormat.values.map((fmt) {
        final selected = _format == fmt;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: fmt != BookFormat.values.last ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _format = fmt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.accentGreen.withOpacity(0.1)
                      : AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selected ? AppTheme.accentGreen : AppTheme.borderColor,
                  ),
                ),
                child: Center(
                  child: Text(
                    fmt.name.toUpperCase(),
                    style: TextStyle(
                      color: selected ? AppTheme.accentGreen : AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
