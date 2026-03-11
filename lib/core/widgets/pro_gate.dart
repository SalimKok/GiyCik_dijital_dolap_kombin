import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/subscription/viewmodel/subscription_viewmodel.dart';
import 'package:gircik/features/subscription/view/pro_paywall_screen.dart';

/// Pro-only özellik kapısı.
/// Pro olmayan kullanıcıya kilit ekranı gösterir,
/// Pro kullanıcıya [child] widget'ını geçirir.
class ProGate extends ConsumerWidget {
  final Widget child;
  final String featureName;

  const ProGate({
    super.key,
    required this.child,
    required this.featureName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);

    if (subscription.isPro) {
      return child;
    }

    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                size: 56,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Pro Özellik',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '"$featureName" özelliği Pro abonelere özeldir.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProPaywallScreen()),
                );
              },
              icon: const Icon(Icons.star_rounded),
              label: const Text('Pro\'ya Yükselt'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
