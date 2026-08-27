import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/memo_screen.dart';
import 'services/classifier_service.dart';

import 'package:nlpmemoflutter/src/rust/frb_generated.dart';
import 'package:nlpmemoflutter/src/rust/api/tokenizer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RustLib.init();

  final data = await rootBundle.load(
    'assets/models/multilingual_e5_small/tokenizer.json',
  );

  await initTokenizer(tokenizerJson: data.buffer.asUint8List());
  final classifierService = ClassifierService();
  await classifierService.initialize();

  runApp(MyApp(classifierService: classifierService));
}

class MyApp extends StatelessWidget {
  final ClassifierService classifierService;

  const MyApp({super.key, required this.classifierService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MemoScreen(classifierService: classifierService));
  }
}
