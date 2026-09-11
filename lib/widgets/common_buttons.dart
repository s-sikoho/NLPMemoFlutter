import 'package:flutter/material.dart';

import '../widgets/train_menu_button.dart';

import '../services/classifier_service.dart';

class MainScaffold extends StatelessWidget {
  final Widget title;
  final Widget body;

  final VoidCallback onToggleTheme;
  final ClassifierService classifierService;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Future<void> Function()? onCategoriesChanged;

  const MainScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.onToggleTheme,
    required this.classifierService,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.onCategoriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: [
          IconButton(
            onPressed: () {
              showLicensePage(context: context, applicationName: 'SortMemo');
            },
            tooltip: 'オープンソースライセンス',
            icon: const Icon(Icons.info_outline),
          ),

          IconButton(
            onPressed: onToggleTheme,
            tooltip: 'テーマ変更',
            icon: const Icon(Icons.dark_mode),
          ),

          TrainMenuButton(classifierService: classifierService,onCategoriesChanged: onCategoriesChanged,),
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
