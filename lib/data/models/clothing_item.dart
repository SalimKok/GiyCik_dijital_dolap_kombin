// lib/data/models/clothing_item.dart

class ClothingItem {
  final String id;
  final String name;
  final String category;
  final String color;
  final int usageCount;
  // TODO: Add imagePath or URL when backend is implemented

  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    this.usageCount = 0,
  });

  ClothingItem copyWith({
    String? id,
    String? name,
    String? category,
    String? color,
    int? usageCount,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}
