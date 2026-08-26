import 'package:flutter/material.dart';

import 'screens/memo_screen.dart';
import 'services/classifier_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final classifierService = ClassifierService();
  await classifierService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MemoScreen(),
    );
  }
}