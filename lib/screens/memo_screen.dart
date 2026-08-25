import 'package:flutter/material.dart';

import '../models/memo.dart';
import '../repositories/memo_repository.dart';
import '../services/classifier_service.dart';

class MemoScreen extends StatefulWidget {
  const MemoScreen({super.key});

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  final MemoRepository _memoRepository = MemoRepository();
  final ClassifierService _classifierService = ClassifierService();

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _contentController =
      TextEditingController();

  List<Memo> _memos = [];

  @override
  void initState() {
    super.initState();

    _loadMemos();
  }

  Future<void> _loadMemos() async {
    final memos = await _memoRepository.getAllMemos();

    setState(() {
      _memos = memos;
    });
  }

  Future<void> _saveMemo() async {
    final title = _titleController.text;
    final content = _contentController.text;

    final categoryId =
        await _classifierService.predictCategory(content);

    final memo = Memo(
      title: title,
      content: content,
      categoryid: categoryId,
    );

    await _memoRepository.insertMemo(memo);

    _titleController.clear();
    _contentController.clear();

    await _loadMemos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
              ),
            ),
            ElevatedButton(
              onPressed: _saveMemo,
              child: const Text('Save'),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _memos.length,
                itemBuilder: (context, index) {
                  final memo = _memos[index];

                  return ListTile(
                    title: Text(memo.title),
                    subtitle: Text(
                      '${memo.content}\ncategoryId: ${memo.categoryid}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}