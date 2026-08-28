import 'package:flutter/material.dart';

import '../models/memo.dart';
import '../models/category.dart';
import '../repositories/memo_repository.dart';
import '../repositories/category_repository.dart';
import '../services/classifier_service.dart';
import '../widgets/memo_card.dart';
import 'memo_edit_screen.dart';

class MemoScreen extends StatefulWidget {
  final ClassifierService classifierService;
  const MemoScreen({super.key, required this.classifierService});

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  final MemoRepository _memoRepository = MemoRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  List<Memo> _memos = [];
  List<Category> _categories = [];

  bool _isLoading = true;
  bool _isTraining = false;

  int? _filterCategoryId;
  String _searchKeyword = '';

  String? _getCategoryName(int categoryId) {
    for (final category in _categories) {
      if (category.id == categoryId) {
        return category.name;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadMemos();
  }

  Future<void> _train() async {
    if (_isTraining) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('学習を実行しますか？'),
          content: const Text('現在の学習用データを使ってカテゴリ分類用データを更新します。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('学習する'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    setState(() {
      _isTraining = true;
    });
    try {
      await widget.classifierService.train();

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('学習が完了しました')));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('学習に失敗しました: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isTraining = false;
        });
      }
    }
  }

  Future<void> _loadMemos() async {
    final memos = await _memoRepository.getFilteredMemos(
      categoryId: _filterCategoryId,
      keyword: _searchKeyword,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _memos = memos;
      _isLoading = false;
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
          return MemoEditScreen(classifierService: widget.classifierService);
        },
      ),
    );
    await _loadMemos();
  }

  Future<void> _openEditScreen(Memo memo) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return MemoEditScreen(
            memo: memo,
            classifierService: widget.classifierService,
          );
        },
      ),
    );
    await _loadMemos();
  }

  Future<void> _deleteMemo(Memo memo) async {
    if (memo.id == null) {
      return;
    }
    await _memoRepository.deleteMemo(memo.id!);
    await _loadMemos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メモ'),

        actions: [
          IconButton(
            onPressed: _isTraining ? null : _train,
            tooltip: '学習',
            icon: _isTraining
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.school),
          ),
        ],
      ),

      body: _buildBody(),

      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateScreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // 検索欄
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'メモを検索',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _searchKeyword = value;
              _loadMemos();
            },
          ),
        ),

        // カテゴリ絞り込み
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonFormField<int?>(
            initialValue: _filterCategoryId,
            decoration: const InputDecoration(
              labelText: 'カテゴリ',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('すべて')),

              ..._categories.map(
                (category) => DropdownMenuItem<int?>(
                  value: category.id,
                  child: Text(category.name),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _filterCategoryId = value;
              });

              _loadMemos();
            },
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
                      categoryName: _getCategoryName(memo.categoryId),
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
