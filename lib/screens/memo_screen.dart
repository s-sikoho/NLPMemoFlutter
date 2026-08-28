import 'package:flutter/material.dart';

import '../models/memo.dart';
import '../repositories/memo_repository.dart';
import '../services/classifier_service.dart';
import 'memo_edit_screen.dart';

class MemoScreen extends StatefulWidget {
  final ClassifierService classifierService;
  const MemoScreen({super.key, required this.classifierService});

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  final MemoRepository _memoRepository = MemoRepository();
  List<Memo> _memos = [];

  bool _isLoading = true;
  bool _isTraining = false;

  @override
  void initState() {
    super.initState();
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
    final memos = await _memoRepository.getAllMemos();
    if (!mounted) {
      return;
    }
    setState(() {
      _memos = memos;
      _isLoading = false;
    });
  }

  Future<void> _openCreateScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const MemoEditScreen();
        },
      ),
    );
    await _loadMemos();
  }

  Future<void> _openEditScreen(Memo memo) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return MemoEditScreen(memo: memo);
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

    if (_memos.isEmpty) {
      return const Center(child: Text('メモがありません'));
    }

    return ListView.builder(
      itemCount: _memos.length,
      itemBuilder: (context, index) {
        final memo = _memos[index];

        return ListTile(
          title: Text(memo.title.isEmpty ? '無題' : memo.title),

          subtitle: Text(
            memo.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          onTap: () {
            _openEditScreen(memo);
          },

          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _deleteMemo(memo);
            },
          ),
        );
      },
    );
  }
}
