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

  final result = await tokenize(text: 'query: 今日は大学に行った');

  print('inputIds: ${result.inputIds}');
  print('attentionMask: ${result.attentionMask}');

  final classifierService = ClassifierService();

  await classifierService.initialize();

  await classifierService.testOnnx(
    inputIds: result.inputIds.map((e) => e.toInt()).toList(),
    attentionMask: result.attentionMask.map((e) => e.toInt()).toList(),
  );

  final embedding = await classifierService.embed(
    inputIds: result.inputIds.map((e) => e.toInt()).toList(),
    attentionMask: result.attentionMask.map((e) => e.toInt()).toList(),
  );

  print('embedding length: ${embedding.length}');
  print('embedding first 10: ${embedding.take(10).toList()}');

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
