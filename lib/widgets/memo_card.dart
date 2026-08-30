import 'package:flutter/material.dart';

import '../models/memo.dart';
import '../models/category.dart';
import '../thema/category_colors.dart';

class MemoCard extends StatelessWidget {
  final Memo memo;
  final Category? category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const MemoCard({
    super.key,
    required this.memo,
    required this.onTap,
    required this.onDelete,
    this.category,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final categoryColorSet = getCategoryColorSet(
      Color(category?.color ?? Colors.grey.toARGB32()),
    );
    return Card(
      color: categoryColorSet.themeColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      memo.title.isEmpty ? '無題' : memo.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: categoryColorSet.textColor,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: categoryColorSet.textColor,
                    ),
                  ),
                ],
              ),

              if (memo.content.isNotEmpty) ...[
                const SizedBox(height: 8),

                Text(
                  memo.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: categoryColorSet.textColor),
                ),
              ],
              if (category != null) ...[
                const SizedBox(height: 12),
                Chip(
                  backgroundColor: categoryColorSet.subColor,
                  label: Text(
                    category!.name,
                    style: TextStyle(color: Colors.black),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
