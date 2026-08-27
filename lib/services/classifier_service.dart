import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

import 'dart:math' as math;

class ClassifierService {
  final OnnxRuntime _ort = OnnxRuntime();
  OrtSession? _session;
  Future<void> initialize() async {
    _session = await _ort.createSessionFromAsset(
      'assets/models/multilingual_e5_small/model.onnx',
    );

    print('E5 model loaded');
  }

  //Future<int> predictCategory(String text) async {
  //final embedding = await _embed(text);
  //return _classify(embedding);
  //}

  Future<String> testOnnx({
    required List<int> inputIds,
    required List<int> attentionMask,
  }) async {
    final session = _session;

    if (session == null) {
      return 'モデルがinitializeされていません(test)';
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

  List<double> meanPooling({
    required List<double> hiddenStates,
    required List<int> attentionMask,
    required int hiddenSize,
  }) {
    final pooled = List<double>.filled(hiddenSize, 0.0);

    var validTokenCount = 0;

    for (var tokenIndex = 0; tokenIndex < attentionMask.length; tokenIndex++) {
      if (attentionMask[tokenIndex] == 0) {
        continue;
      }

      validTokenCount++;

      for (var hiddenIndex = 0; hiddenIndex < hiddenSize; hiddenIndex++) {
        final index = tokenIndex * hiddenSize + hiddenIndex;

        pooled[hiddenIndex] += hiddenStates[index];
      }
    }

    for (var i = 0; i < hiddenSize; i++) {
      pooled[i] /= validTokenCount;
    }

    return pooled;
  }

  List<double> l2Normalize(List<double> vector) {
    var sumSquares = 0.0;

    for (final value in vector) {
      sumSquares += value * value;
    }

    final norm = math.sqrt(sumSquares);

    if (norm == 0.0) {
      return vector;
    }

    return vector.map((value) => value / norm).toList();
  }

  Future<List<double>> embed({
    required List<int> inputIds,
    required List<int> attentionMask,
  }) async {
    final session = _session;

    if (session == null) {
      throw StateError('モデルがinitializeされていません(embed)');
    }

    final inputIds2d = [inputIds];
    final attentionMask2d = [attentionMask];

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

      // 現段階では、実際の出力名を確認してここを決める
      final output = outputs['last_hidden_state'];

      if (output == null) {
        throw StateError('last_hidden_state が見つかりません');
      }

      final shape = output.shape;

      // 例えば [1, 8, 384]
      if (shape.length != 3) {
        throw StateError('想定外の出力shapeです: $shape');
      }

      final hiddenSize = shape[2];

      final flattened = await output.asFlattenedList();

      final hiddenStates = flattened.map((e) => (e as num).toDouble()).toList();

      final pooled = meanPooling(
        hiddenStates: hiddenStates,
        attentionMask: attentionMask,
        hiddenSize: hiddenSize,
      );

      final embedding = l2Normalize(pooled);

      for (final output in outputs.values) {
        await output.dispose();
      }

      return embedding;
    } finally {
      for (final input in inputs.values) {
        await input.dispose();
      }
    }
  }

  double cosineSimilarity(List<double> a, List<double> b) {
    var score = 0.0;

    for (var i = 0; i < a.length; i++) {
      score += a[i] * b[i];
    }

    return score;
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
      return '(モデルがinitializeされていません(debugrun))';
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
