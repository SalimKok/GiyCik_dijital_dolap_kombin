import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gircik/data/models/clothing_item.dart';
import 'package:gircik/features/wardrobe/repository/clothing_repository.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';

class MockClothingRepository extends Mock implements ClothingRepository {}

void main() {
  late MockClothingRepository mockClothingRepository;
  late ProviderContainer container;

  setUp(() {
    mockClothingRepository = MockClothingRepository();
    
    // Default return
    when(() => mockClothingRepository.getClothingItems()).thenAnswer((_) async => []);

    container = ProviderContainer(
      overrides: [
        clothingRepositoryProvider.overrideWithValue(mockClothingRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final item1 = ClothingItem(
    id: '1',
    name: 'Mavi Tişört',
    category: 'Üst',
    color: 'Mavi',
    season: 'Yazlık',
    imageUrl: 'url1',
  );
  
  final item2 = ClothingItem(
    id: '2',
    name: 'Siyah Pantolon',
    category: 'Alt',
    color: 'Siyah',
    season: 'Kışlık',
    imageUrl: 'url2',
  );

  group('WardrobeViewModel Tests', () {
    test('initial state loads items from repository', () async {
      when(() => mockClothingRepository.getClothingItems())
          .thenAnswer((_) async => [item1, item2]);
          
      // read the provider to instantiate it (triggers build and microtask)
      container.read(wardrobeViewModelProvider);
      
      // wait for microtask to complete
      await Future.delayed(Duration.zero);
      
      final state = container.read(wardrobeViewModelProvider);
      expect(state.isLoading, isFalse);
      expect(state.items.length, 2);
    });

    test('selectCategory filters items properly', () async {
      when(() => mockClothingRepository.getClothingItems())
          .thenAnswer((_) async => [item1, item2]);
          
      final viewModel = container.read(wardrobeViewModelProvider.notifier);
      await Future.delayed(Duration.zero);
      
      viewModel.selectCategory('Üst');
      
      final state = container.read(wardrobeViewModelProvider);
      expect(state.selectedCategory, 'Üst');
      expect(state.filteredItems.length, 1);
      expect(state.filteredItems.first.id, '1');
    });

    test('selectSeason filters items properly (Yazlık, Kışlık vb.)', () async {
      when(() => mockClothingRepository.getClothingItems())
          .thenAnswer((_) async => [item1, item2]);
          
      final viewModel = container.read(wardrobeViewModelProvider.notifier);
      await Future.delayed(Duration.zero);
      
      viewModel.selectSeason('Kışlık');
      
      final state = container.read(wardrobeViewModelProvider);
      expect(state.selectedSeason, 'Kışlık');
      expect(state.filteredItems.length, 1);
      expect(state.filteredItems.first.id, '2');
    });

    test('availableColors extracts unique sorted colors including Hepsi', () async {
      when(() => mockClothingRepository.getClothingItems())
          .thenAnswer((_) async => [item1, item2]);
          
      container.read(wardrobeViewModelProvider);
      await Future.delayed(Duration.zero);
      
      final state = container.read(wardrobeViewModelProvider);
      expect(state.availableColors, ['Hepsi', 'Mavi', 'Siyah']);
    });
  });
}
