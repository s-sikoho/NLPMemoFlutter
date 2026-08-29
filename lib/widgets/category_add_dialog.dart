import 'package:flutter/material.dart';

import '../models/category.dart';

class CategoryAddDialog extends StatefulWidget {
  final List<Color> colors;
  const CategoryAddDialog({super.key, required this.colors});
  @override
  State<CategoryAddDialog> createState() => _CategoryAddDialogState();
}

class _CategoryAddDialogState extends State<CategoryAddDialog> {
  String _categoryName = '';
  Color _selectedColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('カテゴリを追加'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'カテゴリ名'),
            onChanged: (value) {
              _categoryName = value;
            },
          ),
          const SizedBox(height: 20),
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
                    border: isSelected
                        ? Border.all(width: 3, color: Colors.black)
                        : null,
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
                name: name,
                isOther: false,
                color: _selectedColor.toARGB32(),
              ),
            );
          },
          child: const Text('追加'),
        ),
      ],
    );
  }
}
