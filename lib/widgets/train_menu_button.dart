import 'package:flutter/material.dart';

import '../services/classifier_service.dart';
import 'train_button.dart';
import '../screens/preset_category_screen.dart';

class TrainMenuButton extends StatelessWidget {
  final ClassifierService classifierService;
  final Future<void> Function()? onCategoriesChanged;

  const TrainMenuButton({
    super.key,
    required this.classifierService,
    this.onCategoriesChanged,
  });

  Future<void> _openMenu(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TrainButton(classifierService: classifierService),
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('プリセットを追加'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();

                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        return PresetCategoryScreen(classifierService: classifierService,);
                      },
                    ),
                  );

                  await onCategoriesChanged?.call();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _openMenu(context),
      tooltip: '学習メニュー',
      icon: const Icon(Icons.school),
    );
  }
}
