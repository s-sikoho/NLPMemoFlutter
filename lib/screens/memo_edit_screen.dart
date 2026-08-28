import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/memo.dart';
import '../repositories/category_repository.dart';
import '../services/memo_save_service.dart';

class MemoEditScreen extends StatefulWidget {
  final Memo? memo;

  const MemoEditScreen({super.key, this.memo});

  @override
  State<MemoEditScreen> createState() => _MemoEditScreenState();
}

class _MemoEditScreenState extends State<MemoEditScreen> {
  final MemoSaveService _memoSaveService = MemoSaveService();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  List<Category> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = true;
  bool get _isEditMode => widget.memo != null;

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

                  DropdownButtonFormField<int>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'カテゴリ'),
                    items: _categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
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
