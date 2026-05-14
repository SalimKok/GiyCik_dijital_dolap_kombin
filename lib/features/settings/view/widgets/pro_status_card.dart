import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/subscription.dart';
import 'package:gircik/features/subscription/view/pro_paywall_screen.dart';
import 'package:gircik/features/settings/view/utils/settings_dialogs.dart';

class UsageBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;

  const UsageBar({super.key, required this.label, required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = (current / max).clamp(0.0, 1.0);
    final isNearLimit = ratio >= 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
            Text('$current / $max', style: theme.textTheme.bodySmall?.copyWith(
              color: isNearLimit ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
              fontWeight: isNearLimit ? FontWeight.bold : FontWeight.normal,
            )),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(
              isNearLimit ? theme.colorScheme.error : Colors.amber.shade600,
            ),
          ),
        ),
      ],
    );
  }
}

class ProStatusCard extends ConsumerWidget {
  final Subscription subscription;

  const ProStatusCard({super.key, required this.subscription});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (subscription.isPro) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade600, Colors.orange.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GiyÇık Pro', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${subscription.planDisplayName} · Tüm özellikler aktif', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => SettingsDialogs.showCancelSubscriptionDialog(context, ref),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                ),
                child: const Text('Aboneliği İptal Et'),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: theme.cardTheme.shadowColor ?? theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.workspace_premium_rounded, color: Colors.amber.shade700),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ücretsiz Plan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('Pro ile sınırsız kullan', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          UsageBar(label: 'Kıyafet', current: subscription.clothingItemCount, max: FreeLimits.maxClothingItems),
          const SizedBox(height: 8),
          UsageBar(label: 'Kombin', current: subscription.outfitCount, max: FreeLimits.maxOutfits),
          const SizedBox(height: 8),
          UsageBar(label: 'AI Öneri', current: subscription.aiUsagesToday, max: FreeLimits.maxTotalAIRecommendations),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProPaywallScreen())),
              icon: const Icon(Icons.star_rounded, size: 18),
              label: const Text('Pro\'ya Yükselt'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
