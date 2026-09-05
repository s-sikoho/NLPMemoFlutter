import 'package:flutter/material.dart';

import '../models/memo.dart';
import '../models/category.dart';

import '../repositories/memo_repository.dart';
import '../repositories/category_repository.dart';

import '../services/classifier_service.dart';
import '../services/category_delete_service.dart';

import '../widgets/memo_card.dart';
import '../widgets/category_add_dialog.dart';
import '../widgets/category_delete_confirm_dialog.dart';
import '../widgets/category_edit_dialog.dart';
import '../widgets/category_list_sheet.dart';
import '../widgets/common_buttons.dart';

import 'memo_edit_screen.dart';

class DayScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ClassifierService classifierService;
  final DateTime date;
  const DayScreen({
    super.key,
    required this.classifierService,
    required this.onToggleTheme,
    required this.date,
  });

  @override
  State<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  final MemoRepository _memoRepository = MemoRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final CategoryDeleteService _categoryDeleteService = CategoryDeleteService();
  final _categoryColors = <Color>[
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
  ];
  List<Memo> _memos = [];
  List<Category> _categories = [];

  bool _isLoading = true;

  int? _filterCategoryId;
  String _searchKeyword = '';

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
    final memos = await _memoRepository.getFilteredMemos(
      categoryId: _filterCategoryId,
      keyword: _searchKeyword,
      date: widget.date,
    );
    final categories = await _categoryRepository.getAllCategories();
    if (!mounted) {
      return;
    }

    setState(() {
      _memos = memos;
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _loadMemos() async {
    final memos = await _memoRepository.getFilteredMemos(
      categoryId: _filterCategoryId,
      keyword: _searchKeyword,
      date: widget.date,
    );
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

  Future<void> _openCreateScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return MemoEditScreen(
            classifierService: widget.classifierService,
            initialScheduledAt: widget.date,
          );
        },
      ),
    );
    await _loadCategories();
    await _loadMemos();
  }

  Future<void> _openEditScreen(Memo memo) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return MemoEditScreen(
            memo: memo,
            classifierService: widget.classifierService,
            initialScheduledAt: widget.date,
          );
        },
      ),
    );
    await _loadCategories();
    await _loadMemos();
  }

  Future<void> _deleteMemo(Memo memo) async {
    if (memo.id == null) {
      return;
    }
    await _memoRepository.deleteMemo(memo.id!);
    await _loadMemos();
  }

  Future<void> _addCategory() async {
    final category = await showDialog<Category>(
      context: context,
      builder: (_) {
        return CategoryAddDialog(colors: _categoryColors);
      },
    );
    if (category == null) {
      return;
    }
    await _categoryRepository.insertCategory(category);
    await _loadCategories();
  }

  Future<void> _editCategory(Category category) async {
    final updatedCategory = await showDialog<Category>(
      context: context,
      builder: (_) {
        return CategoryEditDialog(category: category, colors: _categoryColors);
      },
    );
    if (updatedCategory == null) {
      return;
    }
    await _categoryRepository.updateCategory(updatedCategory);
    await _loadCategories();
    await _loadMemos();
  }

  Future<void> _deleteCategory(Category category) async {
    if (category.isOther) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return CategoryDeleteConfirmDialog(category: category);
      },
    );
    if (confirmed != true) {
      return;
    }
    await _categoryDeleteService.deleteCategory(category.id!);
    // 今絞り込み中のカテゴリを削除した場合は「すべて」に戻す
    if (_filterCategoryId == category.id) {
      _filterCategoryId = null;
    }
    await _loadCategories();
    await _loadMemos();
  }

  Future<void> _showFilterCategorySheet() async {
    final selectedId = await showModalBottomSheet<int>(
      context: context,
      builder: (_) {
        return CategoryListSheet(
          categories: _categories,
          showAllOption: true,
          onAdd: _addCategory,
          onEdit: _editCategory,
          onDelete: _deleteCategory,
        );
      },
    );
    // 画面外タップなど
    // → 現在のフィルタを変更しない
    if (selectedId == null) {
      return;
    }
    setState(() {
      if (selectedId == -1) {
        // 「すべて」
        _filterCategoryId = null;
      } else {
        // 普通のカテゴリ
        _filterCategoryId = selectedId;
      }
    });
    await _loadMemos();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: TextField(
        decoration: const InputDecoration(
          hintText: 'メモを検索',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          _searchKeyword = value;
          _loadMemos();
        },
        onTapOutside: (_) {
          FocusScope.of(context).unfocus();
        },
      ),

      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateScreen,
        child: const Icon(Icons.add),
      ),
      onToggleTheme: widget.onToggleTheme,
      classifierService: widget.classifierService,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${widget.date.year}年${widget.date.month}月${widget.date.day}日',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // カテゴリ絞り込み
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(),
            ),
            title: const Text('カテゴリ'),
            subtitle: Text(
              _filterCategoryId == null
                  ? 'すべて'
                  : _categories
                        .firstWhere(
                          (category) => category.id == _filterCategoryId,
                        )
                        .name,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showFilterCategorySheet,
          ),
        ),

        const SizedBox(height: 4),

        // メモ一覧
        Expanded(
          child: _memos.isEmpty
              ? const Center(child: Text('メモがありません'))
              : ListView.builder(
                  itemCount: _memos.length,
                  itemBuilder: (context, index) {
                    final memo = _memos[index];

                    return MemoCard(
                      memo: memo,
                      category: _getCategory(memo.categoryId),
                      onTap: () {
                        _openEditScreen(memo);
                      },
                      onDelete: () {
                        _deleteMemo(memo);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
