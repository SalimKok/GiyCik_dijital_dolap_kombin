import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/clothing_item.dart';
import 'package:gircik/features/wardrobe/repository/clothing_repository.dart';
import 'package:gircik/features/subscription/viewmodel/subscription_viewmodel.dart';

// ViewModel State
class WardrobeState {
  final bool isLoading;
  final String selectedCategory;
  final String selectedColor;
  final String selectedSeason;
  final List<ClothingItem> items;
  final List<String> categories;
  final List<String> seasons;
  final String? error;

  WardrobeState({
    this.isLoading = false,
    this.selectedCategory = 'Hepsi',
    this.selectedColor = 'Hepsi',
    this.selectedSeason = 'Hepsi',
    this.items = const [],
    this.categories = const [
      'Hepsi',
      'Üst',
      'Alt',
      'Dış giyim',
      'Ayakkabı',
      'Aksesuar',
      'Şal/Eşarp',
    ],
    this.seasons = const [
      'Hepsi',
      'Yazlık',
      'Kışlık',
      'Sonbahar',
      'İlkbahar',
    ],
    this.error,
  });

  WardrobeState copyWith({
    bool? isLoading,
    String? selectedCategory,
    String? selectedColor,
    String? selectedSeason,
    List<ClothingItem>? items,
    List<String>? categories,
    List<String>? seasons,
    String? error,
  }) {
    return WardrobeState(
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSeason: selectedSeason ?? this.selectedSeason,
      items: items ?? this.items,
      categories: categories ?? this.categories,
      seasons: seasons ?? this.seasons,
      error: error,
    );
  }

  List<String> get availableColors {
    final colors = items.map((i) => i.color).where((c) => c.isNotEmpty).toSet().toList();
    colors.sort();
    return ['Hepsi', ...colors];
  }

  List<ClothingItem> get filteredItems {
    var result = items;
    if (selectedCategory != 'Hepsi') {
      result = result.where((i) => i.category == selectedCategory).toList();
    }
    if (selectedColor != 'Hepsi') {
      result = result.where((i) => i.color == selectedColor).toList();
    }
    if (selectedSeason != 'Hepsi') {
      result = result.where((i) => i.season == selectedSeason).toList();
    }
    return result;
  }
}

// ViewModel (Notifier)
class WardrobeViewModel extends Notifier<WardrobeState> {
  late ClothingRepository _repository;

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

  void selectColor(String color) {
    state = state.copyWith(selectedColor: color);
  }

  void selectSeason(String season) {
    state = state.copyWith(selectedSeason: season);
  }

  Future<void> addItem(ClothingItem item, {String? imagePath}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      String? imageUrl = item.imageUrl;
      // Sadece resim yolu verilmişse ve imageUrl henüz yoksa yükle.
      if (imagePath != null && imagePath.isNotEmpty && imageUrl == null) {
        imageUrl = await _repository.uploadClothingImage(imagePath);
      }
      
      final itemToSave = item.copyWith(imageUrl: imageUrl);
      final newItem = await _repository.createClothingItem(itemToSave);
      
      state = state.copyWith(
        isLoading: false, 
        items: [...state.items, newItem]
      );
      
      // Increment subscription counter
      ref.read(subscriptionProvider.notifier).incrementClothingCount();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateItem(ClothingItem item) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedItem = await _repository.updateClothingItem(item.id, item);
      final updatedItems = state.items.map((i) => i.id == item.id ? updatedItem : i).toList();
      state = state.copyWith(
        isLoading: false,
        items: updatedItems,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteItem(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteClothingItem(id);
      final updatedItems = state.items.where((i) => i.id != id).toList();
      state = state.copyWith(
        isLoading: false,
        items: updatedItems,
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
