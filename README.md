# 📚 BookVault — Flutter Android Book Reading App

A clean, dark-themed local book reading app built with Flutter, styled after the **carpinisan-tech.org** aesthetic.

## Color Palette (from your site)
- `#0A0A0A` near-black background
- `#4ADE80` lime-green accent
- Monospace/tech typography, minimal brutalist UI

---

<img width="1915" height="1026" alt="image" src="https://github.com/user-attachments/assets/3b254bea-0cf4-4d24-808c-85fcf21c4c52" />

<img width="1914" height="1024" alt="image" src="https://github.com/user-attachments/assets/f232b23e-d91d-44fd-9e1c-1a36d76a7d0d" />

<img width="1915" height="1032" alt="image" src="https://github.com/user-attachments/assets/91a18fba-2c20-4713-b9bc-01b5213b4ee4" />

## Features
- 📖 Library — store & manage local books (EPUB, PDF, TXT, MOBI)
- 🔍 Search & Filter — by status and format, with sort options
- 📊 Stats — reading stats, format bars, ring chart, top authors
- 🗂 Book Detail — progress tracker, bookmarks, tags
- 📄 Reader — immersive page reader, font size, dark/sepia themes
- 🔖 Bookmarks — add/remove per-book bookmarks
- 💾 Persistence — all data saved locally via shared_preferences
- ➕ Add Books — manual entry + file picker integration

---

## Project Structure
```
lib/
├── main.dart
├── theme/app_theme.dart
├── models/book.dart
├── services/library_service.dart
├── screens/
│   ├── home_screen.dart
│   ├── library_screen.dart
│   ├── book_detail_screen.dart
│   ├── reader_screen.dart
│   ├── add_book_screen.dart
│   └── stats_screen.dart
└── widgets/
    ├── book_card.dart
    ├── book_list_tile.dart
    ├── currently_reading_card.dart
    └── stats_bar.dart
```

---

## Setup
```bash
cd book_app
flutter pub get
flutter run               # dev
flutter build apk --release  # production APK
```

## Dependencies (pubspec.yaml)
```yaml
provider: ^6.1.2
shared_preferences: ^2.3.2
file_picker: ^8.1.2
path_provider: ^2.1.4
uuid: ^4.5.1
intl: ^0.19.0
```

---

## Extending: Real EPUB/PDF Readers

### EPUB
```yaml
epub_view: ^4.3.0
```
```dart
EpubView(controller: EpubController(document: EpubDocument.openFile(File(book.filePath))))
```

### PDF
```yaml
flutter_pdfview: ^1.3.2
```

### File Picker (already included)
```dart
import 'package:file_picker/file_picker.dart';
final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['epub', 'pdf', 'txt', 'mobi'],
);
final path = result?.files.single.path;
```

---

MIT License — styled after carpinisan-tech.org
