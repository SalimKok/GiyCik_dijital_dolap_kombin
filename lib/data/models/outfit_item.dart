import 'package:flutter/material.dart';

class OutfitItemData {
  final String name;
  final IconData icon;
  final String clothingItemId;
  final int displayOrder;

  const OutfitItemData({
    required this.name,
    required this.icon,
    required this.clothingItemId,
    this.displayOrder = 0,
  });

  OutfitItemData copyWith({
    String? name,
    IconData? icon,
    String? clothingItemId,
    int? displayOrder,
  }) {
    return OutfitItemData(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      clothingItemId: clothingItemId ?? this.clothingItemId,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}

class OutfitItem {
  final String id;
  final String title;
  final String style;
  final String season;
  final bool isFavorite;
  final List<OutfitItemData> items;

  const OutfitItem({
    required this.id,
    required this.title,
    required this.style,
    required this.season,
    this.isFavorite = false,
    required this.items,
  });

  OutfitItem copyWith({
    String? id,
    String? title,
    String? style,
    String? season,
    bool? isFavorite,
    List<OutfitItemData>? items,
  }) {
    return OutfitItem(
      id: id ?? this.id,
      title: title ?? this.title,
      style: style ?? this.style,
      season: season ?? this.season,
      isFavorite: isFavorite ?? this.isFavorite,
      items: items ?? this.items,
    );
  }

  factory OutfitItem.fromJson(Map<String, dynamic> json) {
    return OutfitItem(
      id: json['id'].toString(),
      title: json['title'] as String,
      style: json['style'] as String,
      season: json['season'] as String,
      isFavorite: json['is_favorite'] as bool? ?? false,
      items: (json['items'] as List<dynamic>?)?.map((item) {
        // Map backend strings to IconData if needed, or default
        return OutfitItemData(
          name: item['name'] as String? ?? 'Item',
          clothingItemId: item['clothing_item_id'] as String? ?? '',
          displayOrder: item['display_order'] as int? ?? 0,
          icon: Icons.checkroom, 
        );
      }).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'style': style,
      'season': season,
      'is_favorite': isFavorite,
      'items': items.map((i) => {
        'name': i.name,
        'clothing_item_id': i.clothingItemId,
        'display_order': i.displayOrder,
        'icon_name': 'checkroom'
      }).toList(),
    };
  }
}
