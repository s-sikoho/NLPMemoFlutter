import 'package:flutter/material.dart';

import '../models/memo.dart';
import '../repositories/memo_repository.dart';
import 'memo_edit_screen.dart';

class MemoScreen extends StatefulWidget {
  const MemoScreen({super.key});

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  final MemoRepository _memoRepository = MemoRepository();
  List<Memo> _memos = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadMemos();
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
      appBar: AppBar(title: const Text('メモ')),

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
