import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'firebase_options.dart'; // Файл, который создал flutterfire
import 'note_database.dart';
import 'note_repository.dart';
import 'note_viewmodel.dart';
import 'notes_screen.dart';

Future<void> main() async {
  // 1. Обязательная инициализация для Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Инициализация Firebase (ПР 11)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Включаем Crashlytics для отслеживания падений (ПР 11)
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // 4. Твоя текущая инициализация базы данных
  final dao = await NoteDatabase.instance.noteDao;
  final repository = NoteRepository(dao);

  // 5. Запуск приложения
  runApp(
    ChangeNotifierProvider(
      create: (_) => NoteViewModel(repository)..loadNotes(),
      child: const NotesApp(),
    ),
  );
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const NotesScreen(),
    );
  }
}