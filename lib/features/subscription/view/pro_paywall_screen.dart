import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/subscription.dart';
import 'package:gircik/features/subscription/viewmodel/subscription_viewmodel.dart';

class ProPaywallScreen extends ConsumerStatefulWidget {
  const ProPaywallScreen({super.key});

  @override
  ConsumerState<ProPaywallScreen> createState() => _ProPaywallScreenState();
}

class _ProPaywallScreenState extends ConsumerState<ProPaywallScreen> {
  bool _isLoading = false;
  SubscriptionPlan _selectedPlan = SubscriptionPlan.yearly;

  Future<void> _purchase() async {
    setState(() => _isLoading = true);
    await ref.read(subscriptionProvider.notifier).purchasePlan(_selectedPlan);
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Pro\'ya hoş geldin! Tüm özellikler aktif.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      body: SafeArea(
        child: subscription.isPro
            ? _buildAlreadyPro(theme)
            : _buildPaywall(theme),
      ),
    );
  }

  Widget _buildAlreadyPro(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 64, color: Colors.green),
            ),
            const SizedBox(height: 24),
            Text('Zaten Pro\'sun! 🎉', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Tüm özellikler sınırsız olarak aktif.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Geri Dön'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaywall(ThemeData theme) {
    return CustomScrollView(
      slivers: [
        // Geri butonu
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 12),

              // ── Hero banner ──
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade600,
                        Colors.orange.shade700,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'GiyÇık Pro',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tüm özelliklerin kilidini aç, sınırsız kullan.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // ── Özellik listesi ──
              _FeatureItem(
                icon: Icons.checkroom_rounded,
                title: 'Sınırsız Kıyafet',
                subtitle: 'Gardırobuna istediğin kadar kıyafet ekle',
                theme: theme,
              ),
              _FeatureItem(
                icon: Icons.auto_awesome_rounded,
                title: 'Sınırsız Kombin',
                subtitle: 'İstediğin kadar kombin oluştur ve kaydet',
                theme: theme,
              ),
              _FeatureItem(
                icon: Icons.psychology_rounded,
                title: 'Sınırsız AI Önerisi',
                subtitle: 'Yapay zeka ile günlük sınır olmadan kombin al',
                theme: theme,
              ),
              _FeatureItem(
                icon: Icons.calendar_month_rounded,
                title: 'Sınırsız Takvim',
                subtitle: 'Etkinlik ve kombin planlarını sınırsız ekle',
                theme: theme,
              ),
              _FeatureItem(
                icon: Icons.notifications_active_rounded,
                title: 'İleri Düzey Bildirimler',
                subtitle: 'Kişiselleştirilmiş akıllı bildirimler',
                theme: theme,
              ),
              const SizedBox(height: 32),

              // ── Plan seçimi ──
              Text(
                'Planını Seç',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              // Yıllık plan
              _PlanCard(
                title: 'Yıllık',
                price: '₺249,99 / yıl',
                perMonth: '₺20,83 / ay',
                badge: '%58 Tasarruf',
                isSelected: _selectedPlan == SubscriptionPlan.yearly,
                onTap: () => setState(() => _selectedPlan = SubscriptionPlan.yearly),
                theme: theme,
              ),
              const SizedBox(height: 12),

              // Aylık plan
              _PlanCard(
                title: 'Aylık',
                price: '₺49,99 / ay',
                perMonth: null,
                badge: null,
                isSelected: _selectedPlan == SubscriptionPlan.monthly,
                onTap: () => setState(() => _selectedPlan = SubscriptionPlan.monthly),
                theme: theme,
              ),
              const SizedBox(height: 28),

              // ── Satın al butonu ──
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _purchase,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _selectedPlan == SubscriptionPlan.yearly
                              ? 'Yıllık Pro — ₺249,99'
                              : 'Aylık Pro — ₺49,99',
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Alt bilgi
              Text(
                'İstediğin zaman iptal edebilirsin. Ödeme sonrası 7 gün içinde iade hakkın bulunmaktadır.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Kullanım Koşulları',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  Text(' • ', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Gizlilik Politikası',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Yardımcı Widget'lar ──

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeData theme;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.amber.shade700, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 22),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String? perMonth;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _PlanCard({
    required this.title,
    required this.price,
    this.perMonth,
    this.badge,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.amber.withValues(alpha: 0.08)
                : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.amber.shade600 : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Radio
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.amber.shade600 : theme.colorScheme.outline,
                    width: 2,
                  ),
                  color: isSelected ? Colors.amber.shade600 : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              // Plan bilgisi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      price,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    if (perMonth != null)
                      Text(
                        perMonth!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
