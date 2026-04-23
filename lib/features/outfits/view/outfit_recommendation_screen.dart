import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:gircik/features/outfits/viewmodel/outfits_viewmodel.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/data/models/outfit_item.dart';

class OutfitRecommendationScreen extends ConsumerStatefulWidget {
  final OutfitItem? editingOutfit;
  
  const OutfitRecommendationScreen({super.key, this.editingOutfit});

  @override
  ConsumerState<OutfitRecommendationScreen> createState() => _OutfitRecommendationScreenState();
}

class _OutfitRecommendationScreenState extends ConsumerState<OutfitRecommendationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // AI Form state
  String? _selectedSeason;
  String? _selectedEvent;
  String? _selectedWeather;
  String? _selectedStyle;
  bool _isHijabStyle = false;
  
  bool _isLoadingRecommendation = false;
  Map<String, String>? _aiRecommendation;

  // Manual Form state
  final _manualTitleController = TextEditingController();
  String? _manualTopId;
  String? _manualBottomId;
  String? _manualShoesId;
  String? _manualAccessoryId;
  String? _manualShawlId;
  bool _isSavingManual = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingOutfit != null) {
      _tabController = TabController(length: 2, vsync: this, initialIndex: 1); // Open manual tab
      _manualTitleController.text = widget.editingOutfit!.title;
      // Delay population to ensure wardrobe is loaded or accessible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateEditingOutfit();
      });
    } else {
      _tabController = TabController(length: 2, vsync: this);
    }
  }

  void _populateEditingOutfit() {
    if (widget.editingOutfit == null) return;
    final wardrobeState = ref.read(wardrobeViewModelProvider);
    
    for (final outfitItem in widget.editingOutfit!.items) {
      final clothingItem = wardrobeState.items.where((w) => w.id == outfitItem.clothingItemId).firstOrNull;
      if (clothingItem != null) {
        if (clothingItem.category == 'Üst Giyim' || clothingItem.category == 'Üst') _manualTopId = clothingItem.id;
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
    _tabController.dispose();
    super.dispose();
  }

  void _generateRecommendation() async {
    if (_selectedSeason == null || _selectedEvent == null || _selectedWeather == null || _selectedStyle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    setState(() {
      _isLoadingRecommendation = true;
      _aiRecommendation = null;
    });

    try {
      final result = await ref.read(outfitsViewModelProvider.notifier).generateAIOutfit(
        season: _selectedSeason!,
        weather: _selectedWeather!,
        event: _selectedEvent!,
        style: _selectedStyle!,
        isHijab: _isHijabStyle,
      );
      
      if (mounted) {
        setState(() {
          _isLoadingRecommendation = false;
          _aiRecommendation = result.map((key, value) => MapEntry(key, value?.toString() ?? ''));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecommendation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kombin Önerisi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Yapay Zeka', icon: Icon(Icons.auto_awesome_rounded)),
            Tab(text: 'Manuel', icon: Icon(Icons.checkroom_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAITab(context, theme),
          _buildManualTab(context, theme),
        ],
      ),
    );
  }

  Widget _buildAITab(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Yapay zeka asistanın, seçtiğin kriterlere göre sana gardırobundan en uygun kombini önersin.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _buildDropdown(
            label: 'Mevsim',
            value: _selectedSeason,
            items: ['İlkbahar', 'Yaz', 'Sonbahar', 'Kış'],
            onChanged: (val) => setState(() => _selectedSeason = val),
            icon: Icons.filter_drama_rounded,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Hava Durumu',
            value: _selectedWeather,
            items: ['Güneşli', 'Bulutlu', 'Yağmurlu', 'Karlı', 'Rüzgarlı'],
            onChanged: (val) => setState(() => _selectedWeather = val),
            icon: Icons.thermostat_rounded,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Etkinlik',
            value: _selectedEvent,
            items: ['Günlük/Casual', 'İş/Ofis', 'Akşam Yemeği', 'Özel Davet', 'Spor', 'Tatilde'],
            onChanged: (val) => setState(() => _selectedEvent = val),
            icon: Icons.event_rounded,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Tarz',
            value: _selectedStyle,
            items: ['Rahat', 'Şık', 'Sportif', 'Minimalist', 'Bohem', 'Klasik'],
            onChanged: (val) => setState(() => _selectedStyle = val),
            icon: Icons.style_rounded,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Tesettür Kombini Oluştur'),
            subtitle: const Text('Yapay zeka kombine uygun bir şal/eşarp ekler.'),
            value: _isHijabStyle,
            onChanged: (val) => setState(() => _isHijabStyle = val),
            secondary: const Icon(Icons.checkroom_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isLoadingRecommendation ? null : _generateRecommendation,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: _isLoadingRecommendation 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(_isLoadingRecommendation ? 'Kombin Oluşturuluyor...' : 'Bana Kombin Öner'),
          ),
          if (_aiRecommendation != null) ...[
            const SizedBox(height: 32),
            _buildRecommendationCard(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _saveAIOutfit() async {
    if (_aiRecommendation == null) return;
    
    setState(() => _isLoadingRecommendation = true);

    try {
      final wardrobeState = ref.read(wardrobeViewModelProvider);
      
      OutfitItemData? _createData(String? id, String category) {
        if (id == null || id.isEmpty || id == 'null') return null;
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
        _createData(_aiRecommendation!['top_id'], 'Üst Giyim'),
        _createData(_aiRecommendation!['bottom_id'], 'Alt Giyim'),
        _createData(_aiRecommendation!['shoes_id'], 'Ayakkabı'),
        _createData(_aiRecommendation!['outerwear_id'], 'Dış Giyim'),
        _createData(_aiRecommendation!['accessory_id'], 'Aksesuar'),
        _createData(_aiRecommendation!['shawl_id'], 'Şal/Eşarp'),
      ].whereType<OutfitItemData>().toList();

      for (int i = 0; i < items.length; i++) {
        items[i] = items[i].copyWith(displayOrder: i);
      }

      final outfit = OutfitItem(
        id: const Uuid().v4(),
        title: _aiRecommendation!['title'] ?? 'AI Kombini',
        style: _selectedStyle ?? 'Rahat',
        season: _selectedSeason ?? 'Mevsimlik',
        items: items,
      );

      await ref.read(outfitsViewModelProvider.notifier).addOutfit(outfit);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kombin başarıyla kaydedildi!')),
        );
      }
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
        setState(() => _isLoadingRecommendation = false);
      }
    }
  }

  String _getItemName(String? id) {
    if (id == null || id.isEmpty || id == 'null') return 'Seçilmedi';
    final wardrobeState = ref.read(wardrobeViewModelProvider);
    final item = wardrobeState.items.where((i) => i.id == id).firstOrNull;
    return item?.name ?? 'Bulunamadı';
  }

  Widget _buildRecommendationCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.checkroom_rounded, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _aiRecommendation!['title'] ?? 'Kombin',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI Önerisi',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _aiRecommendation!['description'] ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          if (_aiRecommendation!['top_id'] != null)
             _buildOutfitItem(theme, 'Üst Giyim', _getItemName(_aiRecommendation!['top_id']), Icons.dry_cleaning_rounded),
          const SizedBox(height: 12),
          if (_aiRecommendation!['bottom_id'] != null)
             _buildOutfitItem(theme, 'Alt Giyim', _getItemName(_aiRecommendation!['bottom_id']), Icons.airline_seat_legroom_normal_rounded),
          const SizedBox(height: 12),
          if (_aiRecommendation!['shoes_id'] != null)
             _buildOutfitItem(theme, 'Ayakkabı', _getItemName(_aiRecommendation!['shoes_id']), Icons.snowshoeing_rounded),
          const SizedBox(height: 12),
          if (_aiRecommendation!['outerwear_id'] != null && _aiRecommendation!['outerwear_id'] != 'null' && _aiRecommendation!['outerwear_id'] != '')
             _buildOutfitItem(theme, 'Dış Giyim', _getItemName(_aiRecommendation!['outerwear_id']), Icons.dry_cleaning),
          const SizedBox(height: 12),
          if (_aiRecommendation!['accessory_id'] != null && _aiRecommendation!['accessory_id'] != 'null' && _aiRecommendation!['accessory_id'] != '')
             _buildOutfitItem(theme, 'Aksesuar', _getItemName(_aiRecommendation!['accessory_id']), Icons.watch_rounded),
          const SizedBox(height: 12),
          if (_aiRecommendation!['shawl_id'] != null && _aiRecommendation!['shawl_id'] != 'null' && _aiRecommendation!['shawl_id'] != '')
             _buildOutfitItem(theme, 'Şal/Eşarp', _getItemName(_aiRecommendation!['shawl_id']), Icons.checkroom_rounded),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _generateRecommendation,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Yenile'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveAIOutfit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.bookmark_border_rounded),
                  label: const Text('Kaydet'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOutfitItem(ThemeData theme, String category, String item, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            category,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            item,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualTab(BuildContext context, ThemeData theme) {
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
          const SizedBox(height: 16),
          TextFormField(
            controller: _manualTitleController,
            decoration: InputDecoration(
              labelText: 'Kombin Adı',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 24),
          _buildManualSelectionBox(theme, 'Üst Giyim', 'Üst', _manualTopId, Icons.dry_cleaning_rounded, (id) => setState(() => _manualTopId = id)),
          const SizedBox(height: 16),
          _buildManualSelectionBox(theme, 'Alt Giyim', 'Alt', _manualBottomId, Icons.airline_seat_legroom_normal_rounded, (id) => setState(() => _manualBottomId = id)),
          const SizedBox(height: 16),
          _buildManualSelectionBox(theme, 'Ayakkabı', 'Ayakkabı', _manualShoesId, Icons.snowshoeing_rounded, (id) => setState(() => _manualShoesId = id)),
          const SizedBox(height: 16),
          _buildManualSelectionBox(theme, 'Aksesuar', 'Aksesuar', _manualAccessoryId, Icons.watch_rounded, (id) => setState(() => _manualAccessoryId = id)),
          const SizedBox(height: 16),
          _buildManualSelectionBox(theme, 'Şal/Eşarp', 'Şal/Eşarp', _manualShawlId, Icons.checkroom_rounded, (id) => setState(() => _manualShawlId = id)),
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

  void _saveManualOutfit() async {
    if (_manualTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen kombine bir ad verin.')));
      return;
    }

    if (_manualTopId == null && _manualBottomId == null && _manualShoesId == null && _manualAccessoryId == null) {
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
        season: widget.editingOutfit?.season ?? 'Mevsimlik',
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

  Widget _buildManualSelectionBox(ThemeData theme, String title, String category, String? selectedId, IconData icon, Function(String?) onSelected) {
    final itemName = selectedId != null ? _getItemName(selectedId) : '$title Seç';
    final hasSelection = selectedId != null;

    return InkWell(
      onTap: () {
        _showItemSelectionSheet(title, category, onSelected);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasSelection ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.2),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasSelection ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: hasSelection ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                itemName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: hasSelection ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                  fontWeight: hasSelection ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              hasSelection ? Icons.edit_rounded : Icons.add_circle_outline_rounded,
              color: hasSelection ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
