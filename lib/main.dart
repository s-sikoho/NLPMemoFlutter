import 'package:flutter/material.dart';

import 'screens/memo_screen.dart';
import 'services/classifier_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final classifierService = ClassifierService();
  await classifierService.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();
  runApp(
    MyApp(
      classifierService: classifierService,
      notificationService: notificationService,
    ),
  );
}

class MyApp extends StatefulWidget {
  final ClassifierService classifierService;
  final NotificationService notificationService;
  const MyApp({
    super.key,
    required this.classifierService,
    required this.notificationService,
  });
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: _themeMode,
      home: MemoScreen(
        classifierService: widget.classifierService,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
