import 'package:flutter/material.dart';

class OutfitRecommendationScreen extends StatefulWidget {
  const OutfitRecommendationScreen({super.key});

  @override
  State<OutfitRecommendationScreen> createState() => _OutfitRecommendationScreenState();
}

class _OutfitRecommendationScreenState extends State<OutfitRecommendationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // AI Form state
  String? _selectedSeason;
  String? _selectedEvent;
  String? _selectedWeather;
  String? _selectedStyle;
  
  bool _isLoadingRecommendation = false;
  Map<String, String>? _aiRecommendation;

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

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoadingRecommendation = false;
        _aiRecommendation = {
          'title': '$_selectedStyle Tarzı $_selectedEvent Kombini',
          'description': 'Bu $_selectedSeason gününde $_selectedWeather havaya uygun, şık ve rahat bir görünüm.',
          'top': 'Beyaz Keten Gömlek',
          'bottom': 'Açık Mavi Kot Pantolon',
          'shoes': 'Beyaz Sneaker',
          'accessory': 'Güneş Gözlüğü',
        };
      });
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
          const SizedBox(height: 32),
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
                      _aiRecommendation!['title']!,
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
            _aiRecommendation!['description']!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildOutfitItem(theme, 'Üst Giyim', _aiRecommendation!['top']!, Icons.dry_cleaning_rounded),
          const SizedBox(height: 12),
          _buildOutfitItem(theme, 'Alt Giyim', _aiRecommendation!['bottom']!, Icons.airline_seat_legroom_normal_rounded),
          const SizedBox(height: 12),
          _buildOutfitItem(theme, 'Ayakkabı', _aiRecommendation!['shoes']!, Icons.snowshoeing_rounded),
          const SizedBox(height: 12),
          _buildOutfitItem(theme, 'Aksesuar', _aiRecommendation!['accessory']!, Icons.watch_rounded),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
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
                  onPressed: () {},
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
          const SizedBox(height: 24),
          _buildManualSelectionBox(theme, 'Üst Giyim Seç', Icons.dry_cleaning_rounded),
          const SizedBox(height: 16),
          _buildManualSelectionBox(theme, 'Alt Giyim Seç', Icons.airline_seat_legroom_normal_rounded),
          const SizedBox(height: 16),
          _buildManualSelectionBox(theme, 'Ayakkabı Seç', Icons.snowshoeing_rounded),
          const SizedBox(height: 16),
          _buildManualSelectionBox(theme, 'Aksesuar Seç', Icons.watch_rounded),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Kombini Kaydet'),
          ),
        ],
      ),
    );
  }

  Widget _buildManualSelectionBox(ThemeData theme, String title, IconData icon) {
    return InkWell(
      onTap: () {
        // TODO: Open wardrobe selection bottom sheet
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Icon(
              Icons.add_circle_outline_rounded,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
