import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/wardrobe/view/clothing_capture_screen.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/data/models/clothing_item.dart';

class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wardrobeState = ref.watch(wardrobeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dijital Gardırop'),
      ),
      body: wardrobeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 8),
                _buildCategoryChips(theme, ref, wardrobeState),
                const SizedBox(height: 4),
                _buildSummaryRow(context, theme, wardrobeState.filteredItems.length),
                const Divider(height: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: GridView.builder(
                      itemCount: wardrobeState.filteredItems.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        return _WardrobeCard(item: wardrobeState.filteredItems[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ClothingCaptureScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('Yeni kıyafet ekle'),
      ),
    );
  }

  Widget _buildCategoryChips(ThemeData theme, WidgetRef ref, WardrobeState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: state.categories.map((c) {
          final isSelected = c == state.selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(c),
              selected: isSelected,
              onSelected: (_) {
                ref.read(wardrobeViewModelProvider.notifier).selectCategory(c);
              },
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.7),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, ThemeData theme, int visibleCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Text(
            '$visibleCount parça',
            style: theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              // İleride gelişmiş filtre/sort için kullanılabilir
              showModalBottomSheet<void>(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filtreler (yakında)',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Şimdilik sadece kategoriye göre filtreleme yapılıyor. '
                              'İleride renk, mevsim, kullanım sayısı vb. ekleyebiliriz.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.filter_list_rounded, size: 18),
            label: const Text('Filtrele'),
          ),
        ],
      ),
    );
  }
}

class _WardrobeCard extends StatelessWidget {
  const _WardrobeCard({required this.item});

  final ClothingItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardTheme.color,
      shape: theme.cardTheme.shape as RoundedRectangleBorder,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // İleride detay ekranı açılabilir
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. AspectRatio yerine Expanded kullanıyoruz.
              // Böylece metinlerden arta kalan tüm alanı taşmadan doldurur.
              Expanded(
                child: Container(
                  width: double.infinity, // Kutunun sağa-sola tam yaslanması için
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.checkroom_rounded,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.category} • ${item.color}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 8), // 2. Spacer yerine sabit bir boşluk verdik.
              Row(
                children: [
                  Icon(
                    Icons.repeat_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.usageCount} kez giyildi',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
