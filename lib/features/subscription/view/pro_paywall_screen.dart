import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/subscription.dart';
import 'package:gircik/features/subscription/viewmodel/subscription_viewmodel.dart';

import 'package:gircik/features/subscription/view/widgets/already_pro_view.dart';
import 'package:gircik/features/subscription/view/widgets/feature_item.dart';
import 'package:gircik/features/subscription/view/widgets/paywall_hero_banner.dart';
import 'package:gircik/features/subscription/view/widgets/plan_card.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:gircik/core/services/revenue_cat_service.dart';

class ProPaywallScreen extends ConsumerStatefulWidget {
  const ProPaywallScreen({super.key});

  @override
  ConsumerState<ProPaywallScreen> createState() => _ProPaywallScreenState();
}

class _ProPaywallScreenState extends ConsumerState<ProPaywallScreen> {
  bool _isLoading = false;
  Offerings? _offerings;
  Package? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    setState(() => _isLoading = true);
    final offerings = await RevenueCatService.getOfferings();
    if (mounted) {
      setState(() {
        _offerings = offerings;
        _isLoading = false;
        if (offerings != null && offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
          _selectedPackage = offerings.current!.availablePackages.first;
        }
      });
    }
  }

  Future<void> _purchase() async {
    if (_selectedPackage == null) return;
    
    setState(() => _isLoading = true);
    final success = await ref.read(subscriptionProvider.notifier).purchasePackage(_selectedPackage!);
    setState(() => _isLoading = false);

    if (mounted && success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Pro\'ya hoş geldin! Tüm özellikler aktif.'),
        ),
      );
    } else if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Satın alma iptal edildi veya bir hata oluştu.'),
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
            ? const AlreadyProView()
            : _buildPaywall(theme),
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
              const PaywallHeroBanner(),
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
              const FeatureItem(
                icon: Icons.checkroom_rounded,
                title: 'Sınırsız Kıyafet',
                subtitle: 'Gardırobuna istediğin kadar kıyafet ekle',
              ),
              const FeatureItem(
                icon: Icons.auto_awesome_rounded,
                title: 'Sınırsız Kombin',
                subtitle: 'İstediğin kadar kombin oluştur ve kaydet',
              ),
              const FeatureItem(
                icon: Icons.psychology_rounded,
                title: 'Sınırsız AI Önerisi',
                subtitle: 'Yapay zeka ile hiçbir sınır olmadan kombin al',
              ),
              const FeatureItem(
                icon: Icons.calendar_month_rounded,
                title: 'Sınırsız Takvim',
                subtitle: 'Etkinlik ve kombin planlarını sınırsız ekle',
              ),
              const FeatureItem(
                icon: Icons.notifications_active_rounded,
                title: 'İleri Düzey Bildirimler',
                subtitle: 'Kişiselleştirilmiş akıllı bildirimler',
              ),
              const FeatureItem(
                icon: Icons.analytics_rounded,
                title: 'Analitik ve İçgörüler',
                subtitle: 'Gardırobuna dair detaylı istatistikler ve analizler',
              ),
              const SizedBox(height: 32),

              // ── Plan seçimi ──
              Text(
                'Planını Seç',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              if (_isLoading && _offerings == null)
                const Center(child: CircularProgressIndicator())
              else if (_offerings?.current != null)
                ..._offerings!.current!.availablePackages.map((package) {
                  final isYearly = package.packageType == PackageType.annual;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PlanCard(
                      title: isYearly ? 'Yıllık' : 'Aylık',
                      price: package.storeProduct.priceString,
                      perMonth: null, // İsterseniz yıllık plan için aylık hesaplama ekleyebilirsiniz
                      badge: isYearly ? 'Avantajlı' : null,
                      isSelected: _selectedPackage?.identifier == package.identifier,
                      onTap: () => setState(() => _selectedPackage = package),
                    ),
                  );
                }),
              
              if (_offerings?.current == null && !_isLoading)
                const Text('Şu an paketler yüklenemiyor. Lütfen daha sonra tekrar deneyin.', textAlign: TextAlign.center),

              const SizedBox(height: 28),

              // ── Satın al butonu ──
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (_isLoading || _selectedPackage == null) ? null : _purchase,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
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
                          _selectedPackage != null
                              ? 'Satın Al — ${_selectedPackage!.storeProduct.priceString}'
                              : 'Plan Seçiniz',
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
