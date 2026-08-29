import 'package:flutter/material.dart';

import '../models/category.dart';

class CategorySelector extends StatelessWidget {
  final Category? selectedCategory;
  final VoidCallback onTap;
  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: selectedCategory == null
          ? null
          : CircleAvatar(
              radius: 8,
              backgroundColor: Color(selectedCategory!.color),
            ),
      title: Text(selectedCategory?.name ?? 'カテゴリを選択'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
