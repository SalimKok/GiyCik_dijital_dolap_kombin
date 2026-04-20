// lib/data/models/clothing_item.dart

class ClothingItem {
  final String id;
  final String name;
  final String category;
  final String color;
  final int usageCount;
  final String? imageUrl;

  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    this.usageCount = 0,
    this.imageUrl,
  });

  ClothingItem copyWith({
    String? id,
    String? name,
    String? category,
    String? color,
    int? usageCount,
    String? imageUrl,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      usageCount: usageCount ?? this.usageCount,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'].toString(),
      name: json['name'] as String,
      category: json['category'] as String,
      color: json['color'] as String,
      usageCount: json['usage_count'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'color': color,
      'usage_count': usageCount,
      'image_url': imageUrl,
    };
  }
}
