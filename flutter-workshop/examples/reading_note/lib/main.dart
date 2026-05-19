import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/home_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: ReadingNoteApp()));
}

class ReadingNoteApp extends StatelessWidget {
  const ReadingNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '読書メモ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const HomePage(),
    );
  }
}
