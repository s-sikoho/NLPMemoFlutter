import 'package:flutter/material.dart';

import '../widgets/train_button.dart';

import '../services/classifier_service.dart';

class MainScaffold extends StatelessWidget {
  final Widget title;
  final Widget body;

  final VoidCallback onToggleTheme;
  final ClassifierService classifierService;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  final bool isCalendarScreen;

  const MainScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.onToggleTheme,
    required this.classifierService,
    this.floatingActionButton,
    this.bottomNavigationBar,
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

      body: Stack(
        children: [
          Positioned.fill(child: body),
          if (bottomNavigationBar != null)
            Positioned(left: 16, bottom: 16, child: bottomNavigationBar!),
        ],
      ),

      floatingActionButton: floatingActionButton,
    );
  }
}
