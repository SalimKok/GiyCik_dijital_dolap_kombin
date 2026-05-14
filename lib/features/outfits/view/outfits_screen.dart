import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/outfits/view/outfit_recommendation_screen.dart';
import 'package:gircik/features/outfits/viewmodel/outfits_viewmodel.dart';
import 'package:gircik/data/models/subscription.dart';
import '../../subscription/view/pro_paywall_screen.dart';
import '../../subscription/viewmodel/subscription_viewmodel.dart';

import 'package:gircik/features/outfits/view/widgets/outfit_filter_sheet.dart';
import 'package:gircik/features/outfits/view/widgets/outfits_list.dart';

class OutfitsScreen extends ConsumerStatefulWidget {
  const OutfitsScreen({super.key});

  @override
  ConsumerState<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends ConsumerState<OutfitsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const OutfitFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final outfitsState = ref.watch(outfitsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Tüm Kombinler'),
                    Tab(text: 'Favoriler'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () => _showFilterSheet(context),
                  icon: const Icon(Icons.filter_list_rounded),
                  tooltip: 'Filtrele',
                ),
              ),
            ],
          ),
        ),
      ),
      body: outfitsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                OutfitsList(
                  list: outfitsState.filteredOutfits,
                  emptyTitle: 'Henüz kombin eklemedin.',
                  emptySubtitle: 'Yeni bir kombin oluşturarak başla!',
                ),
                OutfitsList(
                  list: outfitsState.favoriteOutfits,
                  emptyTitle: 'Favori kombinin yok.',
                  emptySubtitle: 'Beğendiğin kombinleri favorilerine ekle.',
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final isPro = ref.read(subscriptionProvider).isPro;
          final currentCount = ref.read(outfitsViewModelProvider).outfits.length;
          final canAdd = isPro || currentCount < FreeLimits.maxOutfits;
          
          if (canAdd) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const OutfitRecommendationScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ücretsiz kombin oluşturma limitine ulaştınız. Sınırsız kullanım için Pro\'ya geçin.'),
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProPaywallScreen(),
              ),
            );
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni kombin'),
      ),
    );
  }
}
