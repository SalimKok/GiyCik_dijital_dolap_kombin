import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';

void showWardrobeFilterSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Consumer(
        builder: (context, ref, child) {
          final bottomSheetState = ref.watch(wardrobeViewModelProvider);
          final sheetTheme = Theme.of(context);
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.92,
            builder: (_, scrollController) => SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategoriler',
                    style: sheetTheme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: bottomSheetState.categories.map((c) {
                      final isSelected = c == bottomSheetState.selectedCategory;
                      return ChoiceChip(
                        label: Text(c),
                        selected: isSelected,
                        onSelected: (_) {
                          ref.read(wardrobeViewModelProvider.notifier).selectCategory(c);
                        },
                        selectedColor: sheetTheme.colorScheme.primary.withValues(alpha: 0.15),
                        labelStyle: sheetTheme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? sheetTheme.colorScheme.primary
                              : sheetTheme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? sheetTheme.colorScheme.primary
                              : sheetTheme.colorScheme.outline.withValues(alpha: 0.7),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.white,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Mevsimler',
                    style: sheetTheme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: bottomSheetState.seasons.map((s) {
                      final isSelected = s == bottomSheetState.selectedSeason;
                      return ChoiceChip(
                        label: Text(s),
                        selected: isSelected,
                        onSelected: (_) {
                          ref.read(wardrobeViewModelProvider.notifier).selectSeason(s);
                        },
                        selectedColor: sheetTheme.colorScheme.primary.withValues(alpha: 0.15),
                        labelStyle: sheetTheme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? sheetTheme.colorScheme.primary
                              : sheetTheme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? sheetTheme.colorScheme.primary
                              : sheetTheme.colorScheme.outline.withValues(alpha: 0.7),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.white,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Renkler',
                    style: sheetTheme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: bottomSheetState.availableColors.map((color) {
                      final isSelected = color == bottomSheetState.selectedColor;
                      return ChoiceChip(
                        label: Text(color),
                        selected: isSelected,
                        onSelected: (_) {
                          ref.read(wardrobeViewModelProvider.notifier).selectColor(color);
                        },
                        selectedColor: sheetTheme.colorScheme.primary.withValues(alpha: 0.15),
                        labelStyle: sheetTheme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? sheetTheme.colorScheme.primary
                              : sheetTheme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? sheetTheme.colorScheme.primary
                              : sheetTheme.colorScheme.outline.withValues(alpha: 0.7),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.white,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
