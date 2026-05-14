import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:gircik/features/outfits/viewmodel/outfits_viewmodel.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/data/models/outfit_item.dart';

class ManualOutfitForm extends ConsumerStatefulWidget {
  final OutfitItem? editingOutfit;

  const ManualOutfitForm({super.key, this.editingOutfit});

  @override
  ConsumerState<ManualOutfitForm> createState() => _ManualOutfitFormState();
}

class _ManualOutfitFormState extends ConsumerState<ManualOutfitForm> {
  final _manualTitleController = TextEditingController();
  String? _manualTopId;
  String? _manualOuterwearId;
  String? _manualBottomId;
  String? _manualShoesId;
  String? _manualAccessoryId;
  String? _manualShawlId;
  bool _isSavingManual = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingOutfit != null) {
      _manualTitleController.text = widget.editingOutfit!.title;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateEditingOutfit();
      });
    }
  }

  void _populateEditingOutfit() {
    if (widget.editingOutfit == null) return;
    final wardrobeState = ref.read(wardrobeViewModelProvider);
    
    for (final outfitItem in widget.editingOutfit!.items) {
      final clothingItem = wardrobeState.items.where((w) => w.id == outfitItem.clothingItemId).firstOrNull;
      if (clothingItem != null) {
        if (clothingItem.category == 'Üst Giyim' || clothingItem.category == 'Üst') _manualTopId = clothingItem.id;
        else if (clothingItem.category == 'Dış Giyim' || clothingItem.category == 'Dış giyim') _manualOuterwearId = clothingItem.id;
        else if (clothingItem.category == 'Alt Giyim' || clothingItem.category == 'Alt') _manualBottomId = clothingItem.id;
        else if (clothingItem.category == 'Ayakkabı') _manualShoesId = clothingItem.id;
        else if (clothingItem.category == 'Aksesuar') _manualAccessoryId = clothingItem.id;
        else if (clothingItem.category == 'Şal/Eşarp') _manualShawlId = clothingItem.id;
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _manualTitleController.dispose();
    super.dispose();
  }

  void _saveManualOutfit() async {
    if (_manualTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen kombine bir ad verin.')));
      return;
    }

    if (_manualTopId == null && _manualBottomId == null && _manualShoesId == null && _manualAccessoryId == null && _manualOuterwearId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kombine en az bir parça ekleyin.')));
      return;
    }

    setState(() => _isSavingManual = true);

    try {
      final wardrobeState = ref.read(wardrobeViewModelProvider);
      
      OutfitItemData? _createData(String? id, String category) {
        if (id == null || id.isEmpty) return null;
        final item = wardrobeState.items.where((i) => i.id == id).firstOrNull;
        if (item == null) return null;
        
        return OutfitItemData(
          name: item.name,
          clothingItemId: item.id,
          displayOrder: 0,
          icon: Icons.checkroom,
        );
      }

      final items = [
        _createData(_manualTopId, 'Üst Giyim'),
        _createData(_manualOuterwearId, 'Dış Giyim'),
        _createData(_manualBottomId, 'Alt Giyim'),
        _createData(_manualShoesId, 'Ayakkabı'),
        _createData(_manualAccessoryId, 'Aksesuar'),
        _createData(_manualShawlId, 'Şal/Eşarp'),
      ].whereType<OutfitItemData>().toList();

      for (int i = 0; i < items.length; i++) {
        items[i] = items[i].copyWith(displayOrder: i);
      }

      final outfit = OutfitItem(
        id: widget.editingOutfit?.id ?? const Uuid().v4(),
        title: _manualTitleController.text.trim(),
        style: widget.editingOutfit?.style ?? 'Günlük',
        season: widget.editingOutfit?.season ?? 'İlkbahar',
        isFavorite: widget.editingOutfit?.isFavorite ?? false,
        items: items,
      );

      final outfitsViewModel = ref.read(outfitsViewModelProvider.notifier);
      if (widget.editingOutfit != null) {
        await outfitsViewModel.updateOutfit(outfit);
      } else {
        await outfitsViewModel.addOutfit(outfit);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.editingOutfit != null ? 'Kombin başarıyla güncellendi!' : 'Kombin başarıyla kaydedildi!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
        setState(() => _isSavingManual = false);
      }
    }
  }

  void _showItemSelectionSheet(String title, String category, Function(String?) onSelected) {
    final wardrobeState = ref.read(wardrobeViewModelProvider);
    final categoryItems = wardrobeState.items.where((i) => i.category == category).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (categoryItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Bu kategoride kıyafetiniz bulunmuyor.'),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: categoryItems.length,
                    itemBuilder: (ctx, index) {
                      final item = categoryItems[index];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.checkroom_rounded, color: Theme.of(ctx).colorScheme.primary),
                        ),
                        title: Text(item.name),
                        subtitle: Text(item.color),
                        onTap: () {
                          onSelected(item.id);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              TextButton(
                onPressed: () {
                  onSelected(null);
                  Navigator.pop(ctx);
                },
                child: const Text('Seçimi Temizle', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getItemName(String? id) {
    if (id == null || id.isEmpty || id == 'null') return 'Seçilmedi';
    final wardrobeState = ref.read(wardrobeViewModelProvider);
    final item = wardrobeState.items.where((i) => i.id == id).firstOrNull;
    return item?.name ?? 'Bulunamadı';
  }

  Widget _buildManualSelectionBox(ThemeData theme, String title, String category, String? selectedId, IconData icon, Function(String?) onSelected) {
    final itemName = selectedId != null ? _getItemName(selectedId) : title;
    final hasSelection = selectedId != null;

    return InkWell(
      onTap: () {
        _showItemSelectionSheet(title, category, onSelected);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasSelection ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
            width: hasSelection ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.cardTheme.shadowColor ?? theme.colorScheme.primary.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasSelection ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: hasSelection ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant, size: 24),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                itemName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: hasSelection ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                  fontWeight: hasSelection ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Gardırobundaki parçaları eşleştirerek kendi kombinlerini oluştur.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _manualTitleController,
            decoration: InputDecoration(
              labelText: 'Kombin Adı',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildManualSelectionBox(theme, 'Üst Giyim', 'Üst', _manualTopId, Icons.dry_cleaning_rounded, (id) => setState(() => _manualTopId = id)),
              _buildManualSelectionBox(theme, 'Dış Giyim', 'Dış giyim', _manualOuterwearId, Icons.dry_cleaning, (id) => setState(() => _manualOuterwearId = id)),
              _buildManualSelectionBox(theme, 'Alt Giyim', 'Alt', _manualBottomId, Icons.airline_seat_legroom_normal_rounded, (id) => setState(() => _manualBottomId = id)),
              _buildManualSelectionBox(theme, 'Ayakkabı', 'Ayakkabı', _manualShoesId, Icons.snowshoeing_rounded, (id) => setState(() => _manualShoesId = id)),
              _buildManualSelectionBox(theme, 'Aksesuar', 'Aksesuar', _manualAccessoryId, Icons.watch_rounded, (id) => setState(() => _manualAccessoryId = id)),
              _buildManualSelectionBox(theme, 'Şal/Eşarp', 'Şal/Eşarp', _manualShawlId, Icons.checkroom_rounded, (id) => setState(() => _manualShawlId = id)),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isSavingManual ? null : _saveManualOutfit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isSavingManual 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Kombini Kaydet'),
          ),
        ],
      ),
    );
  }
}
