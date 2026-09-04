import 'package:flutter/material.dart';

import '../services/classifier_service.dart';
import '../widgets/common_buttons.dart';

class CalendarScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ClassifierService classifierService;

  const CalendarScreen({
    super.key,
    required this.onToggleTheme,
    required this.classifierService,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {


  void _openCreateScreen() {
    // 今は未実装
  }

  void _backToMemoScreen() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: const Text('カレンダー'),

      body: const Center(
        child: Text('カレンダー画面'),
      ),

      onToggleTheme: widget.onToggleTheme,
      classifierService: widget.classifierService,
      onCreateMemo: _openCreateScreen,

      isCalendarScreen: true,
      onSwitchScreen: _backToMemoScreen,
    );
  }
}