import 'package:flutter/material.dart';

import '../models/memo.dart';

class MemoCard extends StatelessWidget {
  final Memo memo;
  final String? categoryName;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const MemoCard({
    super.key,
    required this.memo,
    required this.onTap,
    required this.onDelete,
    this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),

                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),

              if (memo.content.isNotEmpty) ...[
                const SizedBox(height: 8),

                Text(
                  memo.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],

              if (categoryName != null) ...[
                const SizedBox(height: 12),

                Chip(
                  label: Text(categoryName!),
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
