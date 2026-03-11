import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/clothing_item.dart';

// ViewModel State
class WardrobeState {
  final bool isLoading;
  final String selectedCategory;
  final List<ClothingItem> items;
  final List<String> categories;
  final String? error;

  WardrobeState({
    this.isLoading = false,
    this.selectedCategory = 'Hepsi',
    this.items = const [],
    this.categories = const [
      'Hepsi',
      'Üst',
      'Alt',
      'Dış giyim',
      'Ayakkabı',
      'Aksesuar',
    ],
    this.error,
  });

  WardrobeState copyWith({
    bool? isLoading,
    String? selectedCategory,
    List<ClothingItem>? items,
    List<String>? categories,
    String? error,
  }) {
    return WardrobeState(
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      items: items ?? this.items,
      categories: categories ?? this.categories,
      error: error,
    );
  }

  List<ClothingItem> get filteredItems {
    if (selectedCategory == 'Hepsi') {
      return items;
    }
    return items.where((i) => i.category == selectedCategory).toList();
  }
}

// ViewModel (Notifier)
class WardrobeViewModel extends Notifier<WardrobeState> {
  @override
  WardrobeState build() {
    // Perform initial load asynchronously
    Future.microtask(() => loadItems());
    return WardrobeState(isLoading: true);
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Simulate API or Database fetch
      await Future<void>.delayed(const Duration(milliseconds: 600));

      // Initial mock data
      final mockData = [
        const ClothingItem(id: '1', name: 'Beyaz Tişört', category: 'Üst', color: 'Beyaz', usageCount: 5),
        const ClothingItem(id: '2', name: 'Mavi Kot Pantolon', category: 'Alt', color: 'Mavi', usageCount: 8),
        const ClothingItem(id: '3', name: 'Bej Trençkot', category: 'Dış giyim', color: 'Bej', usageCount: 2),
        const ClothingItem(id: '4', name: 'Siyah Spor Ayakkabı', category: 'Ayakkabı', color: 'Siyah', usageCount: 10),
        const ClothingItem(id: '5', name: 'Altın Renkli Saat', category: 'Aksesuar', color: 'Altın', usageCount: 3),
      ];

      state = state.copyWith(isLoading: false, items: mockData);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  // Example functionality for adding an item
  void addItem(ClothingItem item) {
    state = state.copyWith(items: [...state.items, item]);
  }
}

// Global Provider
final wardrobeViewModelProvider = NotifierProvider<WardrobeViewModel, WardrobeState>(() {
  return WardrobeViewModel();
});
