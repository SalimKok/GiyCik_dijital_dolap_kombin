import 'package:flutter/material.dart';

class HomeSectionTitle extends StatelessWidget {
  final String title;

  const HomeSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontSize: 15,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
