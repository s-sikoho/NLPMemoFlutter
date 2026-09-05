import 'package:flutter/material.dart';

import '../services/classifier_service.dart';

class TrainButton extends StatefulWidget {
  final ClassifierService classifierService;
  const TrainButton({
    super.key,
    required this.classifierService,
  });
  @override
  State<TrainButton> createState() => _TrainButtonState();
}

class _TrainButtonState extends State<TrainButton> {
  bool _isTraining = false;
  Future<void> _train() async {
    if (_isTraining) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('学習を実行しますか？'),
          content: const Text(
            '現在の学習用データを使ってカテゴリ分類用データを更新します。',
          ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('学習が完了しました'),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('学習に失敗しました: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTraining = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _isTraining ? null : _train,
      tooltip: '学習',
      icon: _isTraining
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.school),
    );
  }
}