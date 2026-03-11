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

  const LaundryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.wearCount,
    required this.maxWear,
    required this.icon,
    required this.status,
  });

  LaundryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? wearCount,
    int? maxWear,
    IconData? icon,
    LaundryStatus? status,
  }) {
    return LaundryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      wearCount: wearCount ?? this.wearCount,
      maxWear: maxWear ?? this.maxWear,
      icon: icon ?? this.icon,
      status: status ?? this.status,
    );
  }
}
