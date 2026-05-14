import 'package:flutter/material.dart';
import 'package:gircik/data/models/outfit_item.dart';
import 'package:gircik/features/outfits/view/widgets/outfit_card.dart';

class OutfitsList extends StatelessWidget {
  final List<OutfitItem> list;
  final String emptyTitle;
  final String emptySubtitle;

  const OutfitsList({
    super.key,
    required this.list,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.style_rounded, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 24),
            Text(emptyTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(emptySubtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final outfit = list[index];
        return OutfitCard(outfit: outfit);
      },
    );
  }
}
