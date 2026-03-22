import 'dart:convert';

enum BookFormat { epub, pdf, txt, mobi }
enum ReadingStatus { unread, reading, finished }

class Book {
  final String id;
  final String title;
  final String author;
  final String filePath;
  final BookFormat format;
  final String? coverPath;
  final int totalPages;
  int currentPage;
  ReadingStatus status;
  final DateTime addedAt;
  DateTime? lastReadAt;
  final String? description;
  final List<String> tags;
  int readingTimeMinutes;
  List<Bookmark> bookmarks;
  List<Highlight> highlights;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    required this.format,
    this.coverPath,
    this.totalPages = 0,
    this.currentPage = 0,
    this.status = ReadingStatus.unread,
    required this.addedAt,
    this.lastReadAt,
    this.description,
    this.tags = const [],
    this.readingTimeMinutes = 0,
    this.bookmarks = const [],
    this.highlights = const [],
  });

  double get progress => totalPages > 0 ? currentPage / totalPages : 0.0;

  String get progressPercent => '${(progress * 100).toStringAsFixed(0)}%';

  String get formatExtension {
    switch (format) {
      case BookFormat.epub: return 'EPUB';
      case BookFormat.pdf: return 'PDF';
      case BookFormat.txt: return 'TXT';
      case BookFormat.mobi: return 'MOBI';
    }
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? filePath,
    BookFormat? format,
    String? coverPath,
    int? totalPages,
    int? currentPage,
    ReadingStatus? status,
    DateTime? addedAt,
    DateTime? lastReadAt,
    String? description,
    List<String>? tags,
    int? readingTimeMinutes,
    List<Bookmark>? bookmarks,
    List<Highlight>? highlights,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      filePath: filePath ?? this.filePath,
      format: format ?? this.format,
      coverPath: coverPath ?? this.coverPath,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      addedAt: addedAt ?? this.addedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      bookmarks: bookmarks ?? this.bookmarks,
      highlights: highlights ?? this.highlights,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'filePath': filePath,
    'format': format.index,
    'coverPath': coverPath,
    'totalPages': totalPages,
    'currentPage': currentPage,
    'status': status.index,
    'addedAt': addedAt.toIso8601String(),
    'lastReadAt': lastReadAt?.toIso8601String(),
    'description': description,
    'tags': tags,
    'readingTimeMinutes': readingTimeMinutes,
    'bookmarks': bookmarks.map((b) => b.toJson()).toList(),
    'highlights': highlights.map((h) => h.toJson()).toList(),
  };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'],
    title: json['title'],
    author: json['author'],
    filePath: json['filePath'],
    format: BookFormat.values[json['format']],
    coverPath: json['coverPath'],
    totalPages: json['totalPages'] ?? 0,
    currentPage: json['currentPage'] ?? 0,
    status: ReadingStatus.values[json['status']],
    addedAt: DateTime.parse(json['addedAt']),
    lastReadAt: json['lastReadAt'] != null ? DateTime.parse(json['lastReadAt']) : null,
    description: json['description'],
    tags: List<String>.from(json['tags'] ?? []),
    readingTimeMinutes: json['readingTimeMinutes'] ?? 0,
    bookmarks: (json['bookmarks'] as List<dynamic>? ?? [])
        .map((b) => Bookmark.fromJson(b))
        .toList(),
    highlights: (json['highlights'] as List<dynamic>? ?? [])
        .map((h) => Highlight.fromJson(h))
        .toList(),
  );

  String toJsonString() => jsonEncode(toJson());
  factory Book.fromJsonString(String jsonString) =>
      Book.fromJson(jsonDecode(jsonString));
}

class Bookmark {
  final String id;
  final int page;
  final String label;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.page,
    required this.label,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'page': page,
    'label': label,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
    id: json['id'],
    page: json['page'],
    label: json['label'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class Highlight {
  final String id;
  final int page;
  final String text;
  final String? note;
  final DateTime createdAt;

  Highlight({
    required this.id,
    required this.page,
    required this.text,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'page': page,
    'text': text,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Highlight.fromJson(Map<String, dynamic> json) => Highlight(
    id: json['id'],
    page: json['page'],
    text: json['text'],
    note: json['note'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
