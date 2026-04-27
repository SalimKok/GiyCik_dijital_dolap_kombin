import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global navigation tab index provider.
/// 0: Ana Sayfa, 1: Gardırop, 2: Kombin, 3: Takvim, 4: Hijyen
class MainNavNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void navigate(int index) => state = index;
}

final mainNavIndexProvider = NotifierProvider<MainNavNotifier, int>(MainNavNotifier.new);
