import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/clothing_item.dart';
import 'package:gircik/features/wardrobe/repository/clothing_repository.dart';

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
  late final ClothingRepository _repository;

  @override
  WardrobeState build() {
    _repository = ref.watch(clothingRepositoryProvider);
    // Perform initial load asynchronously
    Future.microtask(() => loadItems());
    return WardrobeState(isLoading: true);
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final remoteItems = await _repository.getClothingItems();
      state = state.copyWith(isLoading: false, items: remoteItems);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  Future<void> addItem(ClothingItem item, {String? imagePath}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      String? imageUrl;
      if (imagePath != null && imagePath.isNotEmpty) {
        imageUrl = await _repository.uploadClothingImage(imagePath);
      }
      
      final itemToSave = item.copyWith(imageUrl: imageUrl);
      final newItem = await _repository.createClothingItem(itemToSave);
      
      state = state.copyWith(
        isLoading: false, 
        items: [...state.items, newItem]
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Global Provider
final wardrobeViewModelProvider = NotifierProvider<WardrobeViewModel, WardrobeState>(() {
  return WardrobeViewModel();
});

