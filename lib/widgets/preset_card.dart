import 'package:flutter/material.dart';

import '../models/preset_category.dart';

class PresetWidget extends StatelessWidget {
  final PresetCategory preset;
  final bool isAdded;
  final VoidCallback? onTap;

  const PresetWidget({
    super.key,
    required this.preset,
    required this.isAdded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isAdded
        ? Colors.grey.shade400
        : Color(preset.color);
    final exampleTitles = preset.trainingMemos
        .take(3)
        .map((memo) => memo.title)
        .toList();
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              preset.name,
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            const Text('メモの例', style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 4),

            ...exampleTitles.map(
              (title) =>
                  Text('・$title', maxLines: 1, overflow: TextOverflow.ellipsis),
            ),

            const Spacer(),

            Align(
              alignment: Alignment.centerRight,
              child: isAdded
                  ? const Text(
                      '追加済み',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : FilledButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.add),
                      label: const Text('追加'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
