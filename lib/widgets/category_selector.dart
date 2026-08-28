import 'package:flutter/material.dart';

import '../models/category.dart';

class CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onChanged;
  final VoidCallback onAdd;
  final VoidCallback onDelete;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          initialValue: selectedCategoryId,
          decoration: const InputDecoration(labelText: 'カテゴリ'),
          items: categories
              .map(
                (category) => DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),

        Row(
          children: [
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('追加'),
            ),
            TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('削除'),
            ),
          ],
        ),
      ],
    );
  }
}
