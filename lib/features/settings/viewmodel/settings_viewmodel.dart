import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gircik/features/laundry/repository/laundry_repository.dart';
import 'package:gircik/features/laundry/viewmodel/laundry_viewmodel.dart';

class SettingsState {
  final bool notificationsEnabled;
  final bool laundryReminderEnabled;
  final bool eventReminderEnabled;
  final int defaultUsageLimit;
  final bool isLoading;

  SettingsState({
    this.notificationsEnabled = true,
    this.laundryReminderEnabled = true,
    this.eventReminderEnabled = true,
    this.defaultUsageLimit = 3,
    this.isLoading = false,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? laundryReminderEnabled,
    bool? eventReminderEnabled,
    int? defaultUsageLimit,
    bool? isLoading,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      laundryReminderEnabled: laundryReminderEnabled ?? this.laundryReminderEnabled,
      eventReminderEnabled: eventReminderEnabled ?? this.eventReminderEnabled,
      defaultUsageLimit: defaultUsageLimit ?? this.defaultUsageLimit,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    _loadSettings();
    return SettingsState(isLoading: true);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    state = SettingsState(
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
      laundryReminderEnabled: prefs.getBool('laundry_reminder_enabled') ?? true,
      eventReminderEnabled: prefs.getBool('event_reminder_enabled') ?? true,
      defaultUsageLimit: prefs.getInt('default_usage_limit') ?? 3,
      isLoading: false,
    );
  }

  Future<void> setNotificationsEnabled(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  Future<void> setLaundryReminderEnabled(bool value) async {
    state = state.copyWith(laundryReminderEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('laundry_reminder_enabled', value);
  }

  Future<void> setEventReminderEnabled(bool value) async {
    state = state.copyWith(eventReminderEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('event_reminder_enabled', value);
  }

  Future<void> setDefaultUsageLimit(int value) async {
    state = state.copyWith(defaultUsageLimit: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('default_usage_limit', value);
    
    // Update all items in backend for instant feedback in Hygiene section
    try {
      await ref.read(laundryRepositoryProvider).updateAllMaxWear(value);
      // Refresh laundry items to reflect change immediately
      ref.read(laundryViewModelProvider.notifier).loadItems();
    } catch (e) {
      print('Failed to update all items max_wear: $e');
    }
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('daily_recommendation_cache');
    await prefs.remove('daily_recommendation_date');
  }
}

final settingsViewModelProvider = NotifierProvider<SettingsViewModel, SettingsState>(() {
  return SettingsViewModel();
});
