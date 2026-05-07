import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:gircik/features/laundry/viewmodel/laundry_viewmodel.dart';
import 'package:gircik/features/laundry/repository/laundry_repository.dart';
import 'package:gircik/data/models/laundry_item.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/features/wardrobe/repository/clothing_repository.dart';

class MockLaundryRepository extends Mock implements LaundryRepository {}
class MockClothingRepository extends Mock implements ClothingRepository {}

void main() {
  late MockLaundryRepository mockLaundryRepository;
  late MockClothingRepository mockClothingRepository;
  late ProviderContainer container;

  setUp(() {
    mockLaundryRepository = MockLaundryRepository();
    mockClothingRepository = MockClothingRepository();

    when(() => mockLaundryRepository.getLaundryItems()).thenAnswer((_) async => []);
    when(() => mockClothingRepository.getClothingItems()).thenAnswer((_) async => []);

    container = ProviderContainer(
      overrides: [
        laundryRepositoryProvider.overrideWithValue(mockLaundryRepository),
        clothingRepositoryProvider.overrideWithValue(mockClothingRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final itemDirty = LaundryItem(
    id: '1', name: 'Tişört', category: 'Üst', clothingItemId: 'C1',
    wearCount: 3, maxWear: 3, icon: Icons.checkroom, status: LaundryStatus.needsWash
  );
  final itemClean = LaundryItem(
    id: '2', name: 'Pantolon', category: 'Alt', clothingItemId: 'C2',
    wearCount: 0, maxWear: 3, icon: Icons.checkroom, status: LaundryStatus.clean
  );

  group('LaundryViewModel Tests', () {
    test('initial state loads items from repository', () async {
      when(() => mockLaundryRepository.getLaundryItems()).thenAnswer((_) async => [itemDirty, itemClean]);
      
      container.read(laundryViewModelProvider);
      await Future.delayed(Duration.zero); // finish init
      
      final state = container.read(laundryViewModelProvider);
      expect(state.isLoading, isFalse);
      expect(state.items.length, 2);
    });

    test('needsWashItems filters correctly', () async {
      when(() => mockLaundryRepository.getLaundryItems()).thenAnswer((_) async => [itemDirty, itemClean]);
      
      container.read(laundryViewModelProvider);
      await Future.delayed(Duration.zero); // finish init
      
      final state = container.read(laundryViewModelProvider);
      expect(state.needsWashItems.length, 1);
      expect(state.needsWashItems.first.id, '1');
      expect(state.cleanItems.length, 1);
      expect(state.cleanItems.first.id, '2');
    });

    test('moveToClean calls repository and updates status', () async {
      when(() => mockLaundryRepository.getLaundryItems()).thenAnswer((_) async => [itemDirty]);
      when(() => mockLaundryRepository.updateStatus('1', 'clean')).thenAnswer((_) async => itemDirty.copyWith(status: LaundryStatus.clean));
      
      final viewModel = container.read(laundryViewModelProvider.notifier);
      await Future.delayed(Duration.zero);
      
      viewModel.moveToClean('1');
      await Future.delayed(Duration.zero); // wait for updateItemStatus async call
      
      verify(() => mockLaundryRepository.updateStatus('1', 'clean')).called(1);
    });
  });
}
