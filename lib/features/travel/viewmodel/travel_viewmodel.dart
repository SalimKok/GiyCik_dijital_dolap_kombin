import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/travel_plan.dart';
import 'package:gircik/features/travel/repository/travel_repository.dart';

class TravelState {
  final bool isLoading;
  final List<TravelPlan> plans;
  final String? error;

  TravelState({this.isLoading = false, this.plans = const [], this.error});

  TravelState copyWith({bool? isLoading, List<TravelPlan>? plans, String? error}) {
    return TravelState(
      isLoading: isLoading ?? this.isLoading,
      plans: plans ?? this.plans,
      error: error,
    );
  }
}

class TravelViewModel extends Notifier<TravelState> {
  late TravelRepository _repository;

  @override
  TravelState build() {
    _repository = ref.watch(travelRepositoryProvider);
    Future.microtask(() => loadPlans());
    return TravelState();
  }

  Future<void> loadPlans() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final plans = await _repository.getTravelPlans();
      state = state.copyWith(isLoading: false, plans: plans);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<TravelPlan> generatePlan({
    required String destination,
    required String startDate,
    required String endDate,
    required String purpose,
    bool isHijab = false,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final newPlan = await _repository.generateTravelPlan(
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        purpose: purpose,
        isHijab: isHijab,
      );
      state = state.copyWith(isLoading: false, plans: [newPlan, ...state.plans]);
      return newPlan;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw Exception(e.toString());
    }
  }

  Future<void> deletePlan(String id) async {
    try {
      await _repository.deleteTravelPlan(id);
      state = state.copyWith(plans: state.plans.where((p) => p.id != id).toList());
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final travelViewModelProvider = NotifierProvider<TravelViewModel, TravelState>(() {
  return TravelViewModel();
});
