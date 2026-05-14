import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/wardrobe/view/clothing_capture_screen.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/features/laundry/viewmodel/laundry_viewmodel.dart';
import 'package:gircik/features/wardrobe/view/widgets/wardrobe_item_card.dart';
import 'package:gircik/features/wardrobe/view/widgets/wardrobe_summary_header.dart';
import 'package:gircik/data/models/subscription.dart';

import '../../subscription/view/pro_paywall_screen.dart';
import '../../subscription/viewmodel/subscription_viewmodel.dart';

class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardrobeState = ref.watch(wardrobeViewModelProvider);

    return Scaffold(
      body: wardrobeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                WardrobeSummaryHeader(visibleCount: wardrobeState.filteredItems.length),
                const Divider(height: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: GridView.builder(
                      itemCount: wardrobeState.filteredItems.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        final item = wardrobeState.filteredItems[index];
                        final laundryState = ref.watch(laundryViewModelProvider);
                        final dirtyItemIds = laundryState.needsWashItems.map((i) => i.clothingItemId).toSet();
                        final isDirty = dirtyItemIds.contains(item.id);
                        
                        return WardrobeItemCard(item: item, isDirty: isDirty);
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final isPro = ref.read(subscriptionProvider).isPro;
          final currentCount = ref.read(wardrobeViewModelProvider).items.length;
          final canAdd = isPro || currentCount < FreeLimits.maxClothingItems;
          
          if (canAdd) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ClothingCaptureScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ücretsiz kıyafet ekleme limitine ulaştınız. Sınırsız kullanım için Pro\'ya geçin.'),
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
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('Yeni kıyafet ekle'),
      ),
    );
  }
}
