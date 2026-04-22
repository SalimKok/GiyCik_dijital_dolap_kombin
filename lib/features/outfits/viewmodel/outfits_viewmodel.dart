import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/outfit_item.dart';
import 'package:gircik/features/outfits/repository/outfit_repository.dart';

// ViewModel State
class OutfitsState {
  final bool isLoading;
  final List<OutfitItem> outfits;
  final String? error;

  OutfitsState({
    this.isLoading = false,
    this.outfits = const [],
    this.error,
  });

  OutfitsState copyWith({
    bool? isLoading,
    List<OutfitItem>? outfits,
    String? error,
  }) {
    return OutfitsState(
      isLoading: isLoading ?? this.isLoading,
      outfits: outfits ?? this.outfits,
      error: error,
    );
  }

  List<OutfitItem> get favoriteOutfits {
    return outfits.where((outfit) => outfit.isFavorite).toList();
  }
}

// ViewModel (Notifier)
class OutfitsViewModel extends Notifier<OutfitsState> {
  late final OutfitRepository _repository;

  @override
  OutfitsState build() {
    _repository = ref.watch(outfitRepositoryProvider);
    Future.microtask(() => loadOutfits());
    return OutfitsState(isLoading: true);
  }

  Future<void> loadOutfits() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final remoteOutfits = await _repository.getOutfits();
      state = state.copyWith(isLoading: false, outfits: remoteOutfits);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleFavorite(String id) async {
    // Optimistic UI update
    final initialOutfits = state.outfits;
    final updatedOutfits = state.outfits.map((outfit) {
      if (outfit.id == id) {
        return outfit.copyWith(isFavorite: !outfit.isFavorite);
      }
      return outfit;
    }).toList();
    state = state.copyWith(outfits: updatedOutfits);

    try {
      // API call
      await _repository.toggleFavorite(id);
    } catch (e) {
      // Revert on failure
      state = state.copyWith(outfits: initialOutfits, error: e.toString());
    }
  }
  
  Future<void> addOutfit(OutfitItem outfit) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newOutfit = await _repository.createOutfit(outfit);
      state = state.copyWith(
        isLoading: false, 
        outfits: [...state.outfits, newOutfit]
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      throw e; // Hataları UI'da gösterebilmek için fırlatıyoruz
    }
  }

  Future<Map<String, dynamic>> generateAIOutfit({
    required String season,
    required String weather,
    required String event,
    required String style,
  }) async {
    return await _repository.generateAIOutfit(
      season: season,
      weather: weather,
      event: event,
      style: style,
    );
  }
}


// Global Provider
final outfitsViewModelProvider = NotifierProvider<OutfitsViewModel, OutfitsState>(() {
  return OutfitsViewModel();
});
