import 'package:flutter/material.dart';

enum LaundryStatus {
  needsWash,
  washing,
  clean,
}

class LaundryItem {
  final String id;
  final String name;
  final String category;
  final int wearCount;
  final int maxWear;
  final IconData icon;
  final LaundryStatus status;
  final String? imageUrl;

  const LaundryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.wearCount,
    required this.maxWear,
    required this.icon,
    required this.status,
    this.imageUrl,
  });

  LaundryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? wearCount,
    int? maxWear,
    IconData? icon,
    LaundryStatus? status,
    String? imageUrl,
  }) {
    return LaundryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      wearCount: wearCount ?? this.wearCount,
      maxWear: maxWear ?? this.maxWear,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory LaundryItem.fromJson(Map<String, dynamic> json) {
    // Determine status from string
    final statusStr = json['status'] as String? ?? 'clean';
    LaundryStatus parsedStatus;
    switch (statusStr) {
      case 'needsWash':
      case 'needs_wash':
        parsedStatus = LaundryStatus.needsWash;
        break;
      case 'washing':
        parsedStatus = LaundryStatus.washing;
        break;
      default:
        parsedStatus = LaundryStatus.clean;
    }

    // Get clothing_item image if available
    final clothingItem = json['clothing_item'] as Map<String, dynamic>?;

    return LaundryItem(
      id: json['id'].toString(),
      name: clothingItem?['name'] as String? ?? json['name'] as String? ?? 'Bilinmeyen Kıyafet',
      category: clothingItem?['category'] as String? ?? json['category'] as String? ?? 'Kategori Yok',
      wearCount: json['wear_count'] as int? ?? 0,
      maxWear: json['max_wear'] as int? ?? 3,
      icon: Icons.checkroom,
      status: parsedStatus,
      imageUrl: clothingItem?['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    String statusStr = 'needs_wash';
    if (status == LaundryStatus.washing) statusStr = 'washing';
    if (status == LaundryStatus.clean) statusStr = 'clean';

    return {
      'id': id,
      // name, category and icon aren't sent to backend directly (it's a relation), 
      // but we might need to send wear_count or status for updates
      'wear_count': wearCount,
      'max_wear': maxWear,
      'status': statusStr,
    };
  }
}
