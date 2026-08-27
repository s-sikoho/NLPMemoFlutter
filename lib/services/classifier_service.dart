import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

class ClassifierService {
  final OnnxRuntime _ort = OnnxRuntime();
  OrtSession? _session;
  Future<void> initialize() async {
    _session = await _ort.createSessionFromAsset(
      'assets/models/multilingual_e5_small/model.onnx',
    );

    print('E5 model loaded');
  }

  Future<int> predictCategory(String text) async {
    final embedding = await _embed(text);
    return _classify(embedding);
  }

  Future<String> testOnnx({
    required List<int> inputIds,
    required List<int> attentionMask,
  }) async {
    final session = _session;

    if (session == null) {
      return 'モデルがinitializeされていません';
    }

    final inputIds2d = [inputIds];
    final attentionMask2d = [attentionMask];

    print('ONNX inputIds: $inputIds2d');
    print('ONNX attentionMask: $attentionMask2d');

    final inputs = <String, OrtValue>{};

    if (session.inputNames.contains('input_ids')) {
      final value = await OrtValue.fromList(inputIds2d, [1, inputIds.length]);

      inputs['input_ids'] = await value.to(OrtDataType.int64);

      await value.dispose();
    }

    if (session.inputNames.contains('attention_mask')) {
      final value = await OrtValue.fromList(attentionMask2d, [
        1,
        attentionMask.length,
      ]);

      inputs['attention_mask'] = await value.to(OrtDataType.int64);

      await value.dispose();
    }

    if (session.inputNames.contains('token_type_ids')) {
      final tokenTypeIds = [List<int>.filled(inputIds.length, 0)];

      final value = await OrtValue.fromList(tokenTypeIds, [1, inputIds.length]);

      inputs['token_type_ids'] = await value.to(OrtDataType.int64);

      await value.dispose();
    }

    try {
      final outputs = await session.run(inputs);

      final result = StringBuffer();

      result.writeln('推論成功');
      result.writeln();

      result.writeln('Input names:');
      result.writeln(session.inputNames);

      result.writeln();
      result.writeln('Output names:');
      result.writeln(session.outputNames);

      for (final entry in outputs.entries) {
        final output = entry.value;

        result.writeln();
        result.writeln('${entry.key}:');
        result.writeln('shape = ${output.shape}');

        final values = await output.asFlattenedList();

        result.writeln('先頭10個 = ${values.take(10).toList()}');
      }

      for (final output in outputs.values) {
        await output.dispose();
      }

      return result.toString();
    } catch (e) {
      return '推論失敗\n$e';
    } finally {
      for (final input in inputs.values) {
        await input.dispose();
      }
    }
  }

  Future<List<double>> _embed(String text) async {
    return List<double>.filled(384, 0.0);
  }

  int _classify(List<double> embedding) {
    return 1;
  }

  Future<void> train() async {
    // 教師データを取得
    // ↓
    // 各文章を_embed()
    // ↓
    // Logistic Regressionを学習
    // ↓
    // weights / biasを更新
    // ↓
    // SQLiteなどへ保存
  }
  Future<String> debugRunModel() async {
    final session = _session;

    if (session == null) {
      return 'モデルがinitializeされていません';
    }

    // ダミー入力
    // XLM-RoBERTa系で 0=<s>, 2=</s>
    final inputIds = [
      [0, 2],
    ];

    final attentionMask = [
      [1, 1],
    ];

    final inputs = <String, OrtValue>{};

    if (session.inputNames.contains('input_ids')) {
      final value = await OrtValue.fromList(inputIds, [1, 2]);

      inputs['input_ids'] = await value.to(OrtDataType.int64);

      await value.dispose();
    }

    if (session.inputNames.contains('attention_mask')) {
      final value = await OrtValue.fromList(attentionMask, [1, 2]);

      inputs['attention_mask'] = await value.to(OrtDataType.int64);

      await value.dispose();
    }

    if (session.inputNames.contains('token_type_ids')) {
      final value = await OrtValue.fromList(
        [
          [0, 0],
        ],
        [1, 2],
      );

      inputs['token_type_ids'] = await value.to(OrtDataType.int64);

      await value.dispose();
    }

    try {
      final outputs = await session.run(inputs);

      final result = StringBuffer();

      result.writeln('推論成功');
      result.writeln();

      result.writeln('Input names:');
      result.writeln(session.inputNames);

      result.writeln();
      result.writeln('Output names:');
      result.writeln(session.outputNames);

      for (final entry in outputs.entries) {
        final output = entry.value;

        result.writeln();
        result.writeln('${entry.key}:');
        result.writeln('shape = ${output.shape}');

        final values = await output.asFlattenedList();

        result.writeln('先頭10個 = ${values.take(10).toList()}');
      }

      for (final output in outputs.values) {
        await output.dispose();
      }

      return result.toString();
    } catch (e) {
      return '推論失敗\n$e';
    } finally {
      for (final input in inputs.values) {
        await input.dispose();
      }
    }
  }
}
