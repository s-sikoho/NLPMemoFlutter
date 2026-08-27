import 'package:flutter/material.dart';

import '../services/classifier_service.dart';

class MemoScreen extends StatefulWidget {
  final ClassifierService classifierService;

  const MemoScreen({super.key, required this.classifierService});

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  String _result = 'まだ実行していません';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E5 Debug')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            const Text('実行結果', style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            Expanded(child: SingleChildScrollView(child: Text(_result))),
          ],
        ),
      ),
    );
  }
}
