import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gircik/features/outfits/viewmodel/outfits_viewmodel.dart';
import 'package:gircik/features/outfits/repository/outfit_repository.dart';
import 'package:gircik/data/models/outfit_item.dart';

class MockOutfitRepository extends Mock implements OutfitRepository {}

void main() {
  late MockOutfitRepository mockOutfitRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const OutfitItem(id: 'dummy', title: 'dummy', season: 'dummy', style: 'dummy', items: []));
  });

  setUp(() {
    mockOutfitRepository = MockOutfitRepository();
    when(() => mockOutfitRepository.getOutfits()).thenAnswer((_) async => []);

    container = ProviderContainer(
      overrides: [
        outfitRepositoryProvider.overrideWithValue(mockOutfitRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final outfit1 = const OutfitItem(id: '1', title: 'Yaz Kombini', season: 'Yazlık', style: 'Rahat', items: [], isFavorite: false);
  final outfit2 = const OutfitItem(id: '2', title: 'Kış Kombini', season: 'Kışlık', style: 'Şık', items: [], isFavorite: true);

  group('OutfitsViewModel Tests', () {
    test('initial state loads outfits from repository', () async {
      when(() => mockOutfitRepository.getOutfits()).thenAnswer((_) async => [outfit1, outfit2]);
      
      container.read(outfitsViewModelProvider);
      await Future.delayed(Duration.zero); // await init
      
      final state = container.read(outfitsViewModelProvider);
      expect(state.isLoading, isFalse);
      expect(state.outfits.length, 2);
    });

    test('toggleFavorite updates state optimistically', () async {
      when(() => mockOutfitRepository.getOutfits()).thenAnswer((_) async => [outfit1]);
      when(() => mockOutfitRepository.toggleFavorite('1')).thenAnswer((_) async => outfit1.copyWith(isFavorite: true));
      
      final viewModel = container.read(outfitsViewModelProvider.notifier);
      await Future.delayed(Duration.zero);
      
      await viewModel.toggleFavorite('1');
      
      final state = container.read(outfitsViewModelProvider);
      expect(state.outfits.first.isFavorite, isTrue);
      
      verify(() => mockOutfitRepository.toggleFavorite('1')).called(1);
    });

    test('filteredOutfits filters by season and style correctly', () async {
      when(() => mockOutfitRepository.getOutfits()).thenAnswer((_) async => [outfit1, outfit2]);
      
      final viewModel = container.read(outfitsViewModelProvider.notifier);
      await Future.delayed(Duration.zero);
      
      viewModel.selectSeason('Kışlık');
      final state = container.read(outfitsViewModelProvider);
      expect(state.filteredOutfits.length, 1);
      expect(state.filteredOutfits.first.id, '2');
      
      viewModel.selectSeason('Hepsi');
      viewModel.selectStyle('Rahat');
      final state2 = container.read(outfitsViewModelProvider);
      expect(state2.filteredOutfits.length, 1);
      expect(state2.filteredOutfits.first.id, '1');
    });

    test('favoriteOutfits returns only favorited outfits', () async {
      when(() => mockOutfitRepository.getOutfits()).thenAnswer((_) async => [outfit1, outfit2]);
      
      container.read(outfitsViewModelProvider);
      await Future.delayed(Duration.zero);
      
      final state = container.read(outfitsViewModelProvider);
      expect(state.favoriteOutfits.length, 1);
      expect(state.favoriteOutfits.first.id, '2'); // Kış kombini favori
    });

    test('generateAIOutfit passes correct parameters to repository', () async {
      when(() => mockOutfitRepository.generateAIOutfit(
        season: 'Kışlık', weather: 'Karlı', event: 'Toplantı', style: 'Şık', isHijab: false
      )).thenAnswer((_) async => {'recommendation': 'Mock Output'});
      
      final viewModel = container.read(outfitsViewModelProvider.notifier);
      
      final result = await viewModel.generateAIOutfit(
        season: 'Kışlık', weather: 'Karlı', event: 'Toplantı', style: 'Şık', isHijab: false
      );
      
      expect(result['recommendation'], 'Mock Output');
      verify(() => mockOutfitRepository.generateAIOutfit(
        season: 'Kışlık', weather: 'Karlı', event: 'Toplantı', style: 'Şık', isHijab: false
      )).called(1);
    });
  });
}
