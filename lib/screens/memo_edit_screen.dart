import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/memo.dart';

import '../repositories/category_repository.dart';

import '../services/memo_save_service.dart';
import '../services/category_delete_service.dart';
import '../services/classifier_service.dart';

import '../widgets/category_selector.dart';
import '../widgets/category_list_sheet.dart';
import '../widgets/category_edit_dialog.dart';
import '../widgets/category_add_dialog.dart';
import '../widgets/category_delete_confirm_dialog.dart';

class MemoEditScreen extends StatefulWidget {
  final Memo? memo;
  final ClassifierService classifierService;
  const MemoEditScreen({super.key, this.memo, required this.classifierService});
  @override
  State<MemoEditScreen> createState() => _MemoEditScreenState();
}

class _MemoEditScreenState extends State<MemoEditScreen> {
  final MemoSaveService _memoSaveService = MemoSaveService();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
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

  List<Category> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = true;
  bool get _isEditMode => widget.memo != null;
  bool _isPredicting = false;

  @override
  void initState() {
    super.initState();
    final memo = widget.memo;
    if (memo != null) {
      _titleController.text = memo.title;
      _contentController.text = memo.content;
      _selectedCategoryId = memo.categoryId;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryRepository.getAllCategories();
    if (!mounted) {
      return;
    }
    setState(() {
      _categories = categories;
      if (_selectedCategoryId == null && categories.isNotEmpty) {
        _selectedCategoryId = categories.first.id;
      }
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    final categoryId = _selectedCategoryId;
    if (categoryId == null) {
      return;
    }
    final memo = Memo(
      id: widget.memo?.id,
      title: _titleController.text,
      content: _contentController.text,
      categoryId: categoryId,
    );
    if (_isEditMode) {
      await _memoSaveService.updateMemo(memo);
    } else {
      await _memoSaveService.insertMemo(memo);
    }
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
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
    final newId = await _categoryRepository.insertCategory(category);
    await _loadCategories();
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedCategoryId = newId;
    });
  }

  Category? _getSelectedCategory() {
    if (_selectedCategoryId == null) {
      return null;
    }
    for (final category in _categories) {
      if (category.id == _selectedCategoryId) {
        return category;
      }
    }
    return null;
  }

  Future<void> _editCategory(Category category) async {
    final updatedCategory = await showDialog<Category>(
      context: context,
      builder: (context) {
        return CategoryEditDialog(category: category, colors: _categoryColors);
      },
    );
    if (updatedCategory == null) {
      return;
    }
    await _categoryRepository.updateCategory(updatedCategory);
    await _loadCategories();
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
    await _loadCategories();
    // 今編集中のメモが、削除したカテゴリを選択していた場合
    if (_selectedCategoryId == category.id) {
      final other = await _categoryRepository.getOtherCategory();
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedCategoryId = other.id;
      });
    }
  }

  Future<void> _predictCategory() async {
    if (_isPredicting) {
      return;
    }
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final text = '$title $content'.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('タイトルまたは本文を入力してください')));
      return;
    }
    setState(() {
      _isPredicting = true;
    });
    try {
      final categoryId = await widget.classifierService.predictCategory(text);
      // 返されたカテゴリが現在のカテゴリ一覧に存在するか確認
      final exists = _categories.any((category) => category.id == categoryId);
      if (!exists) {
        throw StateError('予測されたカテゴリが存在しません: $categoryId');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedCategoryId = categoryId;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('カテゴリ予測に失敗しました: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isPredicting = false;
        });
      }
    }
  }

  Future<void> _showCategorySelector() async {
    final selectedId = await showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        return CategoryListSheet(
          categories: _categories,
          onEdit: _editCategory,
          onDelete: _deleteCategory,
          onAdd: _addCategory,
        );
      },
    );
    if (selectedId == null) {
      return;
    }
    setState(() {
      _selectedCategoryId = selectedId;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'メモを編集' : '新しいメモ'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _save,
            icon: const Icon(Icons.check),
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'タイトル',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  CategorySelector(
                    selectedCategory: _getSelectedCategory(),
                    onTap: () {
                      _showCategorySelector();
                    },
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _isPredicting ? null : _predictCategory,
                      icon: _isPredicting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(_isPredicting ? '予測中' : 'カテゴリを自動予測'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: 'メモを書いてください',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
