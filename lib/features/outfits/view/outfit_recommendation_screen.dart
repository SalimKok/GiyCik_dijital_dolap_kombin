import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/outfit_item.dart';

import 'package:gircik/features/outfits/view/widgets/ai_recommendation_form.dart';
import 'package:gircik/features/outfits/view/widgets/manual_outfit_form.dart';

class OutfitRecommendationScreen extends ConsumerStatefulWidget {
  final OutfitItem? editingOutfit;
  
  const OutfitRecommendationScreen({super.key, this.editingOutfit});

  @override
  ConsumerState<OutfitRecommendationScreen> createState() => _OutfitRecommendationScreenState();
}

class _OutfitRecommendationScreenState extends ConsumerState<OutfitRecommendationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    if (widget.editingOutfit != null) {
      _tabController = TabController(length: 2, vsync: this, initialIndex: 1); // Open manual tab
    } else {
      _tabController = TabController(length: 2, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          const AIRecommendationForm(),
          ManualOutfitForm(editingOutfit: widget.editingOutfit),
        ],
      ),
    );
  }
}
