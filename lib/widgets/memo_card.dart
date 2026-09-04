import 'package:flutter/material.dart';

import '../models/memo.dart';
import '../models/category.dart';
import '../thema/category_colors.dart';

class MemoCard extends StatelessWidget {
  final Memo memo;
  final Category? category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  String _formatScheduledAt(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final startOfThisWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfNextWeek = startOfThisWeek.add(const Duration(days: 7));
    final startOfWeekAfterNext = startOfThisWeek.add(const Duration(days: 14));
    final weekdays = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'];
    final weekday = weekdays[dateTime.weekday - 1];
    String? relativeText;
    if (targetDate == today) {
      relativeText = '今日';
    } else if (targetDate == tomorrow) {
      relativeText = '明日';
    } else if (!targetDate.isBefore(startOfThisWeek) &&
        targetDate.isBefore(startOfNextWeek)) {
      relativeText = '今週$weekday';
    } else if (!targetDate.isBefore(startOfNextWeek) &&
        targetDate.isBefore(startOfWeekAfterNext)) {
      relativeText = '来週$weekday';
    }
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final dateText = '${dateTime.year}/$month/$day';
    final timeText = '$hour:$minute';
    if (relativeText != null) {
      return '$dateText ($relativeText) $timeText';
    }
    return '$dateText $timeText';
  }

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white, width: 1),
      ),
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
              if (memo.scheduledAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 18,
                      color: categoryColorSet.textColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatScheduledAt(memo.scheduledAt!),
                      style: TextStyle(color: categoryColorSet.textColor),
                    ),
                    if (memo.notificationEnabled) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.notifications,
                        size: 18,
                        color: categoryColorSet.textColor,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
