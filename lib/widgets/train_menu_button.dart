import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/classifier_service.dart';

import 'train_button.dart';
import '../screens/preset_category_screen.dart';

class TrainMenuButton extends StatefulWidget {
  final ClassifierService classifierService;
  final Future<void> Function()? onCategoriesChanged;

  const TrainMenuButton({
    super.key,
    required this.classifierService,
    this.onCategoriesChanged,
  });

  @override
  State<TrainMenuButton> createState() => _TrainMenuButtonState();
}

class _TrainMenuButtonState extends State<TrainMenuButton> {
  final GlobalKey _trainKey = GlobalKey();
  final GlobalKey _presetKey = GlobalKey();
  Future<void> _showTutorialIfNeeded(BuildContext showcaseContext) async {
    final prefs = await SharedPreferences.getInstance();

    final hasSeen = prefs.getBool('train_menu_tutorial_seen') ?? false;

    if (hasSeen) {
      return;
    }

    if (!mounted) {
      return;
    }

    ShowCaseWidget.of(showcaseContext).startShowCase([_trainKey, _presetKey]);
  }

  Future<void> _openMenu(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return ShowCaseWidget(
          onFinish: () async {
            final prefs = await SharedPreferences.getInstance();

            await prefs.setBool('train_menu_tutorial_seen', true);
          },
          builder: (showcaseContext) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showTutorialIfNeeded(showcaseContext);
            });
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Showcase(
                    key: _trainKey,
                    title: '学習',
                    description: '現在のメモとプリセット学習データを使って、自動分類用データを更新します。',
                    child: TrainButton(
                      classifierService: widget.classifierService,
                    ),
                  ),
                  Showcase(
                    key: _presetKey,
                    title: 'プリセットを追加',
                    description: 'あらかじめ用意されたカテゴリと学習データを追加できます。',
                    child: ListTile(
                      leading: const Icon(Icons.playlist_add),
                      title: const Text('プリセットを追加'),
                      onTap: () async {
                        Navigator.of(sheetContext).pop();

                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) {
                              return PresetCategoryScreen(
                                classifierService: widget.classifierService,
                              );
                            },
                          ),
                        );

                        await widget.onCategoriesChanged?.call();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
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
