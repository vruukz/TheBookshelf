import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'services/library_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppTheme.loadAccent();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const BookVaultApp());
}

class BookVaultApp extends StatelessWidget {
  const BookVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LibraryService(),
      child: ValueListenableBuilder<Color>(
        valueListenable: AppTheme.accentNotifier,
        builder: (context, accent, _) => MaterialApp(
          title: 'BookVault',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
