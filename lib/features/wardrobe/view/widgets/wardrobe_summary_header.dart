import 'package:flutter/material.dart';
import 'package:gircik/features/wardrobe/view/widgets/wardrobe_filter_sheet.dart';

class WardrobeSummaryHeader extends StatelessWidget {
  final int visibleCount;

  const WardrobeSummaryHeader({
    super.key,
    required this.visibleCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            onPressed: () => showWardrobeFilterSheet(context),
            icon: const Icon(Icons.filter_list_rounded, size: 18),
            label: const Text('Filtrele'),
          ),
        ],
      ),
    );
  }
}
