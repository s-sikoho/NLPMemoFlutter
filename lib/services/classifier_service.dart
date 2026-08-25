class ClassifierService {
  Future<void> initialize() async {
    // ONNXモデルの読み込み
    // tokenizerの読み込み
    // 保存済みclassifierパラメータの読み込み

    await train();
  }

  Future<int> predictCategory(String text) async {
    final embedding = await _embed(text);

    return _classify(embedding);
  }

  Future<List<double>> _embed(String text) async {
    // 1. textをtokenize
    // 2. ONNXのE5モデルに入力
    // 3. pooling
    // 4. normalize
    // 5. embeddingを返す

    throw UnimplementedError();
  }

  int _classify(List<double> embedding) {
    int? bestCategoryId;
    double maxScore = double.negativeInfinity;

    // 各カテゴリについて
    // score = weight・embedding + bias
    // を計算

    return 1;//いったん1を返す
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