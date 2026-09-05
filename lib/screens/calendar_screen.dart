import 'package:flutter/material.dart';

import '../services/classifier_service.dart';

import '../widgets/common_buttons.dart';

import '../repositories/memo_repository.dart';
import '../repositories/category_repository.dart';

import '../models/memo.dart';
import '../models/category.dart';

class CalendarScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ClassifierService classifierService;

  const CalendarScreen({
    super.key,
    required this.onToggleTheme,
    required this.classifierService,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final MemoRepository _memoRepository = MemoRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  DateTime _focusedMonth = DateTime.now();
  List<Memo> _memos = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  Category? _getCategory(int categoryId) {
    for (final category in _categories) {
      if (category.id == categoryId) {
        return category;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final categories = await _categoryRepository.getAllCategories();
    final memos = await _memoRepository.getFilteredMemos(scheduledOnly: true);
    if (!mounted) {
      return;
    }
    setState(() {
      _categories = categories;
      _memos = memos;
      _isLoading = false;
    });
  }

  Future<void> _loadMemos() async {
    final memos = await _memoRepository.getFilteredMemos(scheduledOnly: true);
    if (!mounted) {
      return;
    }
    setState(() {
      _memos = memos;
    });
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryRepository.getAllCategories();
    if (!mounted) {
      return;
    }
    setState(() {
      _categories = categories;
    });
  }

  Map<DateTime, List<Memo>> _groupMemosByDate() {
    final result = <DateTime, List<Memo>>{};
    for (final memo in _memos) {
      final scheduledAt = memo.scheduledAt;

      if (scheduledAt == null) {
        continue;
      }
      final date = DateTime(
        scheduledAt.year,
        scheduledAt.month,
        scheduledAt.day,
      );
      result.putIfAbsent(date, () => []);
      result[date]!.add(memo);
    }
    return result;
  }

  void _backToMemoScreen() {
    Navigator.of(context).pop();
  }

  void _goPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _goNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return MainScaffold(
      title: const Text('カレンダー'),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _goPreviousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '${_focusedMonth.year}年${_focusedMonth.month}月',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _goNextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Expanded(child: _buildCalendar()),
        ],
      ),

      onToggleTheme: widget.onToggleTheme,
      classifierService: widget.classifierService,
      isCalendarScreen: true,
    );
  }

  Widget _buildCalendar() {
    final groupedMemos = _groupMemosByDate();
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final totalCells = firstWeekday - 1 + daysInMonth;

    return Column(
      children: [
        _buildWeekdayHeader(),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              final day = index - (firstWeekday - 1) + 1;
              if (day <= 0) {
                return const SizedBox();
              }
              final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
              final memos = groupedMemos[date] ?? [];
              return _buildDayCell(date, memos);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(DateTime date, List<Memo> memos) {
    final colors = memos
        .map((memo) => _getCategory(memo.categoryId))
        .whereType<Category>()
        .map((category) => Color(category.color))
        .toSet()
        .toList();
    final visibleColors = colors.take(3).toList();

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${date.day}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: visibleColors.map((color) {
                  return Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }
}
