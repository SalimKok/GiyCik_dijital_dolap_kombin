import 'package:flutter/material.dart';
import 'package:gircik/features/travel/view/travel_assistant_screen.dart';
import 'package:gircik/features/pro_features/view/wardrobe_analytics_screen.dart';

class ProFeaturesHubScreen extends StatefulWidget {
  const ProFeaturesHubScreen({super.key});

  @override
  State<ProFeaturesHubScreen> createState() => _ProFeaturesHubScreenState();
}

class _ProFeaturesHubScreenState extends State<ProFeaturesHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          color: theme.scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.amber.shade600,
            indicatorWeight: 3,
            labelColor: Colors.amber.shade700,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            tabs: const [
              Tab(
                icon: Icon(Icons.analytics_rounded),
                text: 'Analitik',
              ),
              Tab(
                icon: Icon(Icons.flight_takeoff_rounded),
                text: 'Valiz Asistanı',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(), // İçerdeki kaydırmalarla çakışmamak için
            children: const [
              WardrobeAnalyticsScreen(),
              TravelAssistantScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
