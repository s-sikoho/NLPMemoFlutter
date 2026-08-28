import 'package:flutter/material.dart';

import '../models/category.dart';

class CategoryDeleteConfirmDialog extends StatelessWidget {
  final Category category;
  const CategoryDeleteConfirmDialog({
    super.key,
    required this.category,
  });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('カテゴリを削除しますか？'),
      content: Text(
        '「${category.name}」を削除します。\n'
        'このカテゴリのメモは「その他」に移動します。',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text('削除'),
        ),
      ],
    );
  }
}