import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/calendar_event.dart';
import 'package:gircik/features/laundry/viewmodel/laundry_viewmodel.dart';
import 'package:gircik/features/style_calendar/viewmodel/style_calendar_viewmodel.dart';
import 'package:gircik/core/providers/navigation_provider.dart';

class UpcomingInfoRow extends ConsumerWidget {
  final int laundryCount;
  final String nextEventTitle;
  final String nextEventTime;
  final CalendarEvent? nextEvent;

  const UpcomingInfoRow({
    super.key,
    required this.laundryCount,
    required this.nextEventTitle,
    required this.nextEventTime,
    this.nextEvent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.local_laundry_service_rounded,
            title: 'Yıkanması Gerekenler',
            subtitle: laundryCount > 0 
              ? '$laundryCount kıyafet' 
              : 'Yok',
            color: Theme.of(context).colorScheme.primary,
            onTap: () {
              // Kirli tab'ına yönlendir, ardından Hijyen sekmesine (index 5) git
              ref.read(laundryViewModelProvider.notifier).navigateToDirtyTab();
              ref.read(mainNavIndexProvider.notifier).navigate(5);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: Icons.event_rounded,
            title: 'Yaklaşan Etkinlik',
            subtitle: nextEvent != null ? '$nextEventTime $nextEventTitle' : 'Yok',
            color: Theme.of(context).colorScheme.primary,
            onTap: nextEvent != null ? () {
              // Takvim sekmesi index 3, ilgili günü seç
              ref.read(styleCalendarViewModelProvider.notifier)
                  .selectDay(nextEvent!.date, nextEvent!.date);
              ref.read(mainNavIndexProvider.notifier).navigate(3);
            } : () {},
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.cardTheme.shadowColor ?? theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                const Spacer(flex: 3),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(flex: 1),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
