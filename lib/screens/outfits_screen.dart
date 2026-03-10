import 'package:flutter/material.dart';
import 'package:gircik/screens/outfit_recommendation_screen.dart';

class OutfitsScreen extends StatefulWidget {
  const OutfitsScreen({super.key});

  @override
  State<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends State<OutfitsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for outfits
  final List<Map<String, dynamic>> _outfits = [
    {
      'id': '1',
      'title': 'Hafta Sonu Yürüyüş',
      'style': 'Sportif',
      'season': 'İlkbahar',
      'isFavorite': true,
      'items': [
        {'name': 'Kapüşonlu Sweat', 'icon': Icons.dry_cleaning_rounded},
        {'name': 'Gri Eşofman', 'icon': Icons.airline_seat_legroom_normal_rounded},
        {'name': 'Spor Ayakkabı', 'icon': Icons.snowshoeing_rounded},
      ],
    },
    {
      'id': '2',
      'title': 'Ofis Günlüğü',
      'style': 'Şık / Klasik',
      'season': 'Sonbahar',
      'isFavorite': false,
      'items': [
        {'name': 'Beyaz Gömlek', 'icon': Icons.dry_cleaning_rounded},
        {'name': 'Siyah Pantolon', 'icon': Icons.airline_seat_legroom_normal_rounded},
        {'name': 'Klasik Ayakkabı', 'icon': Icons.snowshoeing_rounded},
        {'name': 'Deri Kemer', 'icon': Icons.watch_rounded},
      ],
    },
    {
      'id': '3',
      'title': 'Rahat Akşam',
      'style': 'Casual',
      'season': 'Yaz',
      'isFavorite': true,
      'items': [
        {'name': 'Kısa Kol Tişört', 'icon': Icons.dry_cleaning_rounded},
        {'name': 'Açık Mavi Şort', 'icon': Icons.airline_seat_legroom_normal_rounded},
        {'name': 'Sneaker', 'icon': Icons.snowshoeing_rounded},
      ],
    },
    {
      'id': '4',
      'title': 'Kış Yemeği',
      'style': 'Şık',
      'season': 'Kış',
      'isFavorite': false,
      'items': [
        {'name': 'Bordo Kazak', 'icon': Icons.dry_cleaning_rounded},
        {'name': 'Koyu Kot Pantolon', 'icon': Icons.airline_seat_legroom_normal_rounded},
        {'name': 'Bot', 'icon': Icons.snowshoeing_rounded},
        {'name': 'Atkı', 'icon': Icons.watch_rounded},
      ],
    },
  ];

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

  void _toggleFavorite(String id) {
    setState(() {
      final index = _outfits.indexWhere((element) => element['id'] == id);
      if (index != -1) {
        _outfits[index]['isFavorite'] = !(_outfits[index]['isFavorite'] as bool);
      }
    });
  }

  List<Map<String, dynamic>> get _favoriteOutfits =>
      _outfits.where((outfit) => outfit['isFavorite'] == true).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kombinlerim'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tüm Kombinler'),
            Tab(text: 'Favoriler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOutfitsList(_outfits, 'Henüz kombin eklemedin.', 'Yeni bir kombin oluşturarak başla!', theme),
          _buildOutfitsList(_favoriteOutfits, 'Favori kombinin yok.', 'Beğendiğin kombinleri favorilerine ekle.', theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const OutfitRecommendationScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Öneri Al'),
      ),
    );
  }

  Widget _buildOutfitsList(List<Map<String, dynamic>> list, String emptyTitle, String emptySubtitle, ThemeData theme) {
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
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80), // Bottom padding for FAB
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final outfit = list[index];
        return _buildOutfitCard(outfit, theme);
      },
    );
  }

  Widget _buildOutfitCard(Map<String, dynamic> outfit, ThemeData theme) {
    final bool isFavorite = outfit['isFavorite'] as bool;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outfit['title'],
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildTag(outfit['style'], theme.colorScheme.primary),
                          _buildTag(outfit['season'], theme.colorScheme.secondary),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _toggleFavorite(outfit['id']),
                  icon: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.red : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // Items section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: (outfit['items'] as List<dynamic>).map((item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['name'] as String,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
