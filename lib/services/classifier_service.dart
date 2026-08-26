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
}