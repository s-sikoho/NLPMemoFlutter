import 'package:flutter/material.dart';

import '../services/classifier_service.dart';
import '../services/notification_service.dart';

import '../widgets/common_buttons.dart';

import '../repositories/memo_repository.dart';
import '../repositories/category_repository.dart';

import '../models/memo.dart';
import '../models/category.dart';

import 'day_screen.dart';

class CalendarScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ClassifierService classifierService;
  final NotificationService notificationService;

  const CalendarScreen({
    super.key,
    required this.onToggleTheme,
    required this.classifierService,
    required this.notificationService,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final MemoRepository _memoRepository = MemoRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  DateTime _selectedDate = DateTime.now();
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

  List<Memo> _getSelectedDateMemos() {
    return _memos.where((memo) {
      final scheduledAt = memo.scheduledAt;

      if (scheduledAt == null) {
        return false;
      }

      return scheduledAt.year == _selectedDate.year &&
          scheduledAt.month == _selectedDate.month &&
          scheduledAt.day == _selectedDate.day;
    }).toList();
  }

  Future<void> _openDayScreen(DateTime date) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return DayScreen(
            date: date,
            onToggleTheme: widget.onToggleTheme,
            classifierService: widget.classifierService,
            notificationService: widget.notificationService,
          );
        },
      ),
    );

    // DayScreenから戻ってきた後に最新データを再取得
    await _loadCategories();
    await _loadMemos();
  }

  void _backToMemoScreen() {
    Navigator.of(context).pop();
  }

  void _goPreviousMonth() {
    final newMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    setState(() {
      _focusedMonth = newMonth;
      _selectedDate = newMonth;
    });
  }

  void _goNextMonth() {
    final newMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    setState(() {
      _focusedMonth = newMonth;
      _selectedDate = newMonth;
    });
  }

  void _goToday() {
    final now = DateTime.now();
    setState(() {
      _focusedMonth = DateTime(now.year, now.month);
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return MainScaffold(
      title: const Text('カレンダー'),

      body: Stack(
        children: [
          Column(
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
              _buildCalendar(),
              const Divider(),
              _buildSelectedDateHeader(),
              Expanded(child: _buildSelectedMemoList()),
            ],
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              heroTag: 'todayButton',
              onPressed: _goToday,
              icon: const Icon(Icons.today),
              label: const Text('今日'),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              heroTag: 'detailButton',
              onPressed: () {
                _openDayScreen(_selectedDate);
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('この日のメモ'),
            ),
          ),
        ],
      ),
      onToggleTheme: widget.onToggleTheme,
      classifierService: widget.classifierService,
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
    final totalCells = firstWeekday + daysInMonth;
    return Column(
      children: [
        _buildWeekdayHeader(),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            final day = index - firstWeekday + 1;
            if (day <= 0) {
              return const SizedBox();
            }
            final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
            final memos = groupedMemos[date] ?? [];
            return _buildDayCell(date, memos);
          },
        ),
      ],
    );
  }

  Widget _buildDayCell(DateTime date, List<Memo> memos) {
    final now = DateTime.now();

    final isSelected =
        date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;

    Color? dayColor;

    if (date.weekday == DateTime.sunday) {
      dayColor = Colors.red;
    } else if (date.weekday == DateTime.saturday) {
      dayColor = Colors.blue;
    }
    final colors = memos
        .map((memo) => _getCategory(memo.categoryId))
        .whereType<Category>()
        .map((category) {
          if (category.isOther) {
            return Colors.grey;
          }
          return Color(category.color);
        })
        .toSet()
        .toList();
    final visibleColors = colors.take(3).toList();
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : dayColor,
                      fontWeight: isSelected
                          ? FontWeight.w900
                          : FontWeight.normal,
                    ),
                  ),
                ),
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
      ),
    );
  }

  Widget _buildSelectedDateHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '${_selectedDate.month}月${_selectedDate.day}日',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSelectedMemoList() {
    final memos = _getSelectedDateMemos();

    if (memos.isEmpty) {
      return const Center(child: Text('この日のメモはありません'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
      itemCount: memos.length,
      itemBuilder: (context, index) {
        final memo = memos[index];

        return _buildSelectedMemoCard(memo);
      },
    );
  }

  Widget _buildSelectedMemoCard(Memo memo) {
    final category = _getCategory(memo.categoryId);

    final color = category == null || category.isOther
        ? Colors.grey
        : Color(category.color);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        title: Text(memo.title),
        subtitle: memo.content.isNotEmpty
            ? Text(memo.content, maxLines: 2, overflow: TextOverflow.ellipsis)
            : null,
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    return Row(
      children: weekdays.map((day) {
        Color? color;
        if (day == '日') {
          color = Colors.red;
        } else if (day == '土') {
          color = Colors.blue;
        }
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
        );
      }).toList(),
    );
  }
}
