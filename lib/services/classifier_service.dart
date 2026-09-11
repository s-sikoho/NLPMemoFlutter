import 'package:flutter/services.dart';
import 'package:nlpmemoflutter/repositories/category_repository.dart';
import 'package:nlpmemoflutter/services/preset_category_service.dart';

import '../repositories/category_embedding_repository.dart';
import '../repositories/memo_repository.dart';
import '../models/category_embedding.dart';

import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:nlpmemoflutter/src/rust/frb_generated.dart';
import 'package:nlpmemoflutter/src/rust/api/tokenizer.dart';

import 'dart:math' as math;

class ClassifierService {
  final OnnxRuntime _ort = OnnxRuntime();
  OrtSession? _session;
  final CategoryEmbeddingRepository _categoryEmbeddingRepository =
      CategoryEmbeddingRepository();
  final MemoRepository _memoRepository = MemoRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final PresetCategoryService _presetCategoryService = PresetCategoryService();

  Future<void> initialize() async {
    await RustLib.init();

    final data = await rootBundle.load(
      'assets/models/multilingual_e5_small/tokenizer.json',
    );

    await initTokenizer(tokenizerJson: data.buffer.asUint8List());

    await _initializeOnnx();
  }

  Future<void> _initializeOnnx() async {
    _session = await _ort.createSessionFromAsset(
      'assets/models/multilingual_e5_small/model.onnx',
    );
  }

  Future<int> predictCategory(String text) async {
    // 1. tokenizer
    final tokenized = await tokenize(text: 'query: $text');

    // 2. embedding
    final embedding = await embed(
      inputIds: tokenized.inputIds.map((e) => e.toInt()).toList(),
      attentionMask: tokenized.attentionMask.map((e) => e.toInt()).toList(),
    );

    // 3. SQLiteから分類用データを取得
    final categoryEmbeddings = await _categoryEmbeddingRepository.getAll();

    // 4. 最も近いカテゴリを探す
    int? bestCategoryId;
    double bestScore = double.negativeInfinity;

    for (final category in categoryEmbeddings) {
      final score = cosineSimilarity(embedding, category.embedding);

      if (score > bestScore) {
        bestScore = score;
        bestCategoryId = category.categoryId;
      }
    }

    if (bestCategoryId == null) {
      throw StateError('分類可能なカテゴリがありません');
    }

    return bestCategoryId;
  }

  Future<void> train() async {
    // 1. categoryId ごとに文章をまとめる
    final textsByCategory = <int, List<String>>{};

    // 2. カテゴリ取得
    final categories = await _categoryRepository.getAllCategories();

    // 再学習が必要なカテゴリだけ抽出
    final targetCategories = categories
        .where((category) => category.id != null && category.needsTraining)
        .toList();

    final targetCategoryIds = targetCategories
        .map((category) => category.id!)
        .toSet();

    // 再学習対象がなければ終了
    if (targetCategoryIds.isEmpty) {
      return;
    }

    // 3. プリセット学習データを取得
    final presets = await _presetCategoryService.loadPresets();

    for (final category in targetCategories) {
      if (category.presetId == null) {
        continue;
      }

      for (final preset in presets) {
        if (preset.presetId == category.presetId) {
          for (final memo in preset.trainingMemos) {
            textsByCategory
                .putIfAbsent(category.id!, () => [])
                .add('${memo.title} ${memo.content}');
          }

          break;
        }
      }
    }

    // 4. ユーザーのメモを取得
    final confirmedMemos = await _memoRepository.getAllMemos();

    for (final memo in confirmedMemos) {
      // 再学習対象カテゴリ以外は無視
      if (!targetCategoryIds.contains(memo.categoryId)) {
        continue;
      }

      textsByCategory
          .putIfAbsent(memo.categoryId, () => [])
          .add('${memo.title} ${memo.content}');
    }

    // 5. 各カテゴリについて代表 embedding を作る
    for (final category in targetCategories) {
      final categoryId = category.id!;

      final texts = textsByCategory[categoryId] ?? [];

      if (texts.isEmpty) {
        await _categoryEmbeddingRepository.deleteByCategoryId(categoryId);
        await _categoryRepository.markTrainingCompleted(categoryId);
        continue;
      }

      final embeddings = <List<double>>[];

      // 6. 各教師文章を embedding 化
      for (final text in texts) {
        final tokenized = await tokenize(text: 'passage: $text');

        final embedding = await embed(
          inputIds: tokenized.inputIds.map((e) => e.toInt()).toList(),
          attentionMask: tokenized.attentionMask.map((e) => e.toInt()).toList(),
        );

        embeddings.add(embedding);
      }

      // 7. embedding の平均
      final representativeEmbedding = _averageEmbeddings(embeddings);

      // 8. normalize
      final normalizedEmbedding = l2Normalize(representativeEmbedding);

      // 9. embedding保存
      await _categoryEmbeddingRepository.save(
        CategoryEmbedding(
          categoryId: categoryId,
          embedding: normalizedEmbedding,
        ),
      );

      // 10. このカテゴリの学習完了
      await _categoryRepository.markTrainingCompleted(categoryId);
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

  List<double> _averageEmbeddings(List<List<double>> embeddings) {
    if (embeddings.isEmpty) {
      throw ArgumentError('embedding がありません');
    }

    final dimension = embeddings.first.length;

    final average = List<double>.filled(dimension, 0.0);

    for (final embedding in embeddings) {
      if (embedding.length != dimension) {
        throw StateError('embedding の次元が一致していません');
      }

      for (var i = 0; i < dimension; i++) {
        average[i] += embedding[i];
      }
    }

    for (var i = 0; i < dimension; i++) {
      average[i] /= embeddings.length;
    }

    return average;
  }
}
