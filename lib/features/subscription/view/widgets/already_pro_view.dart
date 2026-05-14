import 'package:flutter/material.dart';

class AlreadyProView extends StatelessWidget {
  const AlreadyProView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 64, color: Colors.green),
            ),
            const SizedBox(height: 24),
            Text('Zaten Pro\'sun! 🎉', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Tüm özellikler sınırsız olarak aktif.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Geri Dön'),
            ),
          ],
        ),
      ),
    );
  }
}
