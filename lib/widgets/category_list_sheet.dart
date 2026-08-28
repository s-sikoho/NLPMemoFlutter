import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryListSheet extends StatelessWidget {
  final List<Category> categories;
  final Future<void> Function(Category category) onEdit;
  final Future<void> Function(Category category) onDelete;
  final Future<void> Function() onAdd;
  const CategoryListSheet({
    super.key,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...categories.map((category) {
            return ListTile(
              leading: CircleAvatar(
                radius: 8,
                backgroundColor: Color(category.color),
              ),
              title: Text(category.name),
              // 行自体を押したら、
              // このカテゴリを選択したとしてidを親に返す
              onTap: () {
                Navigator.of(context).pop(category.id);
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: '編集',
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    onPressed: () async {
                      // 一度BottomSheetを閉じる
                      Navigator.of(context).pop();
                      // 親から渡された編集処理を実行
                      await onEdit(category);
                    },
                  ),
                  // 「その他」は削除させない
                  if (!category.isOther)
                    IconButton(
                      tooltip: '削除',
                      icon: const Icon(
                        Icons.delete_outline,
                      ),
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