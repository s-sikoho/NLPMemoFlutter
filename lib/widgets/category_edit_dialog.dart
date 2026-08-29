import 'package:flutter/material.dart';

import '../models/category.dart';

class CategoryEditDialog extends StatefulWidget {
  final Category category;
  final List<Color> colors;

  const CategoryEditDialog({
    super.key,
    required this.category,
    required this.colors,
  });

  @override
  State<CategoryEditDialog> createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends State<CategoryEditDialog> {
  late String _categoryName;  
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();

    _categoryName = widget.category.name;
    _selectedColor = Color(widget.category.color);
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('カテゴリを編集'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: widget.category.name,
            decoration: const InputDecoration(labelText: 'カテゴリ名'),
            onChanged: (value) {
              _categoryName = value;
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.colors.map((color) {
              final isSelected = color.toARGB32() == _selectedColor.toARGB32();

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(width: 3) : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () {
            final name = _categoryName.trim();
            if (name.isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              Category(
                id: widget.category.id,
                name: name,
                isOther: widget.category.isOther,
                color: _selectedColor.toARGB32(),
              ),
            );
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
