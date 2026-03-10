import 'package:flutter/material.dart';

class LaundryScreen extends StatefulWidget {
  const LaundryScreen({super.key});

  @override
  State<LaundryScreen> createState() => _LaundryScreenState();
}

class _LaundryScreenState extends State<LaundryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock Data definitions
  final List<Map<String, dynamic>> _needsWash = [
    {
      'id': '1',
      'name': 'Beyaz Keten Gömlek',
      'category': 'Üst Giyim',
      'wearCount': 3,
      'maxWear': 3,
      'icon': Icons.dry_cleaning_rounded,
    },
    {
      'id': '2',
      'name': 'Siyah Kot Pantolon',
      'category': 'Alt Giyim',
      'wearCount': 5,
      'maxWear': 5,
      'icon': Icons.airline_seat_legroom_normal_rounded,
    },
  ];

  final List<Map<String, dynamic>> _washing = [
    {
      'id': '3',
      'name': 'Spor Tişört',
      'category': 'Üst Giyim',
      'wearCount': 1,
      'maxWear': 1,
      'icon': Icons.dry_cleaning_rounded,
    },
  ];

  final List<Map<String, dynamic>> _clean = [
    {
      'id': '4',
      'name': 'Açık Mavi Gömlek',
      'category': 'Üst Giyim',
      'wearCount': 0,
      'maxWear': 3,
      'icon': Icons.dry_cleaning_rounded,
    },
    {
      'id': '5',
      'name': 'Gri Eşofman',
      'category': 'Alt Giyim',
      'wearCount': 0,
      'maxWear': 2,
      'icon': Icons.airline_seat_legroom_normal_rounded,
    },
    {
      'id': '6',
      'name': 'Bordo Kazak',
      'category': 'Üst Giyim',
      'wearCount': 1,
      'maxWear': 4,
      'icon': Icons.dry_cleaning_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _moveToWashing(Map<String, dynamic> item) {
    setState(() {
      _needsWash.removeWhere((element) => element['id'] == item['id']);
      _washing.add(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['name']} yıkamaya eklendi')),
    );
  }

  void _moveToClean(Map<String, dynamic> item) {
    setState(() {
      _washing.removeWhere((element) => element['id'] == item['id']);
      item['wearCount'] = 0; // Reset wear count
      _clean.add(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['name']} temiz olarak işaretlendi')),
    );
  }

  void _moveToNeedsWash(Map<String, dynamic> item) {
    setState(() {
      _clean.removeWhere((element) => element['id'] == item['id']);
      item['wearCount'] = item['maxWear']; // Max out wear count for demo
      _needsWash.add(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['name']} kirlilere eklendi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hijyen & Yıkama'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Kullanım Sınırı Hakkında'),
                  content: const Text(
                    'Kıyafetlerinizin türüne göre belirlenen kullanım sınırlarına ulaşıldığında, o kıyafet otomatik olarak kirliler (Yıkanması Gerekenler) listesine düşer.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Anladım'),
                    )
                  ],
                ),
              );
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          tabs: [
            Tab(text: 'Kirliler (${_needsWash.length})', icon: const Icon(Icons.warning_amber_rounded)),
            Tab(text: 'Yıkanıyor (${_washing.length})', icon: const Icon(Icons.local_laundry_service_rounded)),
            Tab(text: 'Temiz (${_clean.length})', icon: const Icon(Icons.check_circle_outline_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLaundryList(_needsWash, 'Kirli Sepeti Boş', 'Harika! Yıkanmayı bekleyen kıyafetin yok.', LaundryState.needsWash, theme),
          _buildLaundryList(_washing, 'Makine Boş', 'Şu an yıkanan bir kıyafet bulunmuyor.', LaundryState.washing, theme),
          _buildLaundryList(_clean, 'Temiz Kıyafet Yok', 'Dolabında giyilmeye hazır kıyafetin kalmamış gibi görünüyor.', LaundryState.clean, theme),
        ],
      ),
    );
  }

  Widget _buildLaundryList(List<Map<String, dynamic>> items, String emptyTitle, String emptySubtitle, LaundryState state, ThemeData theme) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                state == LaundryState.needsWash ? Icons.check_circle_outline_rounded :
                state == LaundryState.washing ? Icons.local_laundry_service_rounded :
                Icons.dry_cleaning_rounded,
                size: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                emptyTitle,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item, state, theme);
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, LaundryState state, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(state, theme),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item['icon'], color: _getIconColor(state, theme), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        item['category'],
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state == LaundryState.clean 
                          ? '${item['maxWear'] - item['wearCount']} kullanım kaldı'
                          : 'Kullanım sınırı doldu',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: state == LaundryState.clean ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.error,
                          fontWeight: state == LaundryState.clean ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildActionButton(item, state, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> item, LaundryState state, ThemeData theme) {
    if (state == LaundryState.needsWash) {
      return IconButton.filled(
        onPressed: () => _moveToWashing(item),
        icon: const Icon(Icons.local_laundry_service_rounded),
        tooltip: 'Yıkamaya At',
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
        ),
      );
    } else if (state == LaundryState.washing) {
      return IconButton.filled(
        onPressed: () => _moveToClean(item),
        icon: const Icon(Icons.check_rounded),
        tooltip: 'Temiz Olarak İşaretle',
        style: IconButton.styleFrom(
          backgroundColor: Colors.green.shade100,
          foregroundColor: Colors.green.shade800,
        ),
      );
    } else {
      // Clean state
      return IconButton.outlined(
        onPressed: () => _moveToNeedsWash(item),
        icon: const Icon(Icons.water_drop_rounded),
        tooltip: 'Kirlilere Taşı',
        style: IconButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
        ),
      );
    }
  }

  Color _getIconBackgroundColor(LaundryState state, ThemeData theme) {
    if (state == LaundryState.needsWash) return theme.colorScheme.errorContainer.withValues(alpha: 0.5);
    if (state == LaundryState.washing) return theme.colorScheme.primaryContainer.withValues(alpha: 0.5);
    return Colors.green.shade50;
  }

  Color _getIconColor(LaundryState state, ThemeData theme) {
    if (state == LaundryState.needsWash) return theme.colorScheme.error;
    if (state == LaundryState.washing) return theme.colorScheme.primary;
    return Colors.green.shade700;
  }
}

enum LaundryState {
  needsWash,
  washing,
  clean,
}
