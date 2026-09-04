import 'package:flutter/material.dart';

import '../widgets/train_button.dart';

import '../services/classifier_service.dart';

class MainScaffold extends StatelessWidget {
  final Widget title;
  final Widget body;

  final VoidCallback onToggleTheme;
  final ClassifierService classifierService;
  final VoidCallback onCreateMemo;
  final VoidCallback onSwitchScreen;

  final bool isCalendarScreen;

  const MainScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.onToggleTheme,
    required this.classifierService,
    required this.onCreateMemo,
    required this.onSwitchScreen,
    required this.isCalendarScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: [
          IconButton(
            onPressed: onToggleTheme,
            tooltip: 'テーマ変更',
            icon: const Icon(Icons.dark_mode),
          ),

          TrainButton(classifierService: classifierService),
        ],
      ),

      body: body,

      floatingActionButton: FloatingActionButton(
        onPressed: onCreateMemo,
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: onSwitchScreen,
              tooltip: isCalendarScreen ? 'メモ一覧' : 'カレンダー',
              icon: Icon(isCalendarScreen ? Icons.notes : Icons.calendar_month),
            ),
          ],
        ),
      ),
    );
  }
}
