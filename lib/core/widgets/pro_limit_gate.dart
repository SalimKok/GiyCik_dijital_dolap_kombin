import 'package:flutter/material.dart';
import 'package:gircik/features/subscription/view/pro_paywall_screen.dart';

/// Kullanım sınırına ulaşıldığında Pro yükseltme dialog'u gösterir.
/// [canProceed] true ise [onAllowed] çağrılır, false ise paywall'a yönlendirir.
class ProLimitGate {
  /// Limit kontrolü yapar. Limit doluysa dialog gösterir ve false döner.
  static bool check({
    required BuildContext context,
    required bool canProceed,
    required String featureName,
    required int currentCount,
    required int maxCount,
  }) {
    if (canProceed) return true;

    // Limit dolmuş — dialog göster
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 40,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Limite Ulaştın!',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ücretsiz planda en fazla $maxCount $featureName ekleyebilirsin. '
                'Şu an $currentCount / $maxCount kullanıyorsun.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Pro\'ya yükselterek sınırsız kullanabilirsin.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProPaywallScreen()),
                );
              },
              icon: const Icon(Icons.star_rounded, size: 18),
              label: const Text('Pro\'ya Yükselt'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    return false;
  }
}
