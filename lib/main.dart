import 'package:flutter/material.dart';

import 'screens/memo_screen.dart';
import 'services/classifier_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final classifierService = ClassifierService();
  await classifierService.initialize();

  runApp(
    MyApp(
      classifierService: classifierService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ClassifierService classifierService;

  const MyApp({super.key, required this.classifierService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MemoScreen(classifierService: classifierService));
  }
}
