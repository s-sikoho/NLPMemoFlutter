import 'package:flutter/material.dart';

import '../models/category.dart';

class CategoryListSheet extends StatelessWidget {
  final List<Category> categories;

  final Future<void> Function(Category category) onEdit;
  final Future<void> Function(Category category) onDelete;
  final Future<void> Function() onAdd;
  final bool showAllOption;
  const CategoryListSheet({
    super.key,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
    this.showAllOption = false,
  });
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text(
              'カテゴリを選択',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // フィルタ用途のときだけ表示
          if (showAllOption)
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('すべて'),
              onTap: () {
                Navigator.of(context).pop(-1);
              },
            ),
          ...categories.where((category) => !category.isOther).map((category) {
            return ListTile(
              leading: CircleAvatar(
                radius: 8,
                backgroundColor: Color(category.color),
              ),
              title: Text(category.name),
              // 普通のカテゴリを選んだ場合
              onTap: () {
                Navigator.of(context).pop(category.id);
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: '編集',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () async {
                      Navigator.of(context).pop();

                      await onEdit(category);
                    },
                  ),
                  if (!category.isOther)
                    IconButton(
                      tooltip: '削除',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        Navigator.of(context).pop();

                        await onDelete(category);
                      },
                    ),
                ],
              ),
            );
          }),
          const Divider(),

          ...categories.where((category) => category.isOther).map((category) {
            return ListTile(
              leading: CircleAvatar(
                radius: 8,
                backgroundColor: Color(category.color),
              ),
              title: Text(category.name),
              onTap: () {
                Navigator.of(context).pop(category.id);
              },
            );
          }),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('カテゴリを追加'),
            onTap: () async {
              Navigator.of(context).pop();
              await onAdd();
            },
          ),
        ],
      ),
    );
  }
}
