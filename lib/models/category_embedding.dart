import 'dart:typed_data';

class CategoryEmbedding {
  final int categoryId;
  final List<double> embedding;

  const CategoryEmbedding({
    required this.categoryId,
    required this.embedding,
  });

  factory CategoryEmbedding.fromMap(
    Map<String, Object?> map,
  ) {
    final bytes = map['embedding'] as Uint8List;

    final floatList = bytes.buffer.asFloat32List(
      bytes.offsetInBytes,
      bytes.lengthInBytes ~/ 4,
    );

    return CategoryEmbedding(
      categoryId: map['category_id'] as int,
      embedding: floatList.toList(),
    );
  }

  Map<String, Object?> toMap() {
    final floatList = Float32List.fromList(embedding);

    return {
      'category_id': categoryId,
      'embedding': floatList.buffer.asUint8List(),
    };
  }
}