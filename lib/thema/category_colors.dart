import 'package:flutter/material.dart';

class CategoryColorSet {
  final Color themeColor;
  final Color subColor;
  final Color textColor;

  const CategoryColorSet({
    required this.themeColor,
    required this.subColor,
    required this.textColor,
  });
}

final categoryColors = <CategoryColorSet>[
  CategoryColorSet(
    themeColor: Colors.blue,
    subColor: Colors.blue.shade100,
    textColor: Colors.white,
  ),
  CategoryColorSet(
    themeColor: Colors.red,
    subColor: Colors.red.shade100,
    textColor: Colors.white,
  ),
  CategoryColorSet(
    themeColor: Colors.green,
    subColor: Colors.green.shade100,
    textColor: Colors.white,
  ),
  CategoryColorSet(
    themeColor: Colors.orange,
    subColor: Colors.orange.shade100,
    textColor: Colors.black,
  ),
  CategoryColorSet(
    themeColor: Colors.purple,
    subColor: Colors.purple.shade100,
    textColor: Colors.white,
  ),
  CategoryColorSet(
    themeColor: Colors.teal,
    subColor: Colors.teal.shade100,
    textColor: Colors.white,
  ),
  CategoryColorSet(
    themeColor: Colors.pink,
    subColor: Colors.pink.shade100,
    textColor: Colors.black,
  ),
  CategoryColorSet(
    themeColor: Colors.brown,
    subColor: Colors.brown.shade100,
    textColor: Colors.white,
  ),
];

CategoryColorSet getCategoryColorSet(Color color) {
  return categoryColors.firstWhere(
    (set) => set.themeColor.toARGB32() == color.toARGB32(),
    orElse: () => CategoryColorSet(
      themeColor: Colors.grey,
      subColor: Colors.grey.shade100,
      textColor: Colors.black,
    ),
  );
}