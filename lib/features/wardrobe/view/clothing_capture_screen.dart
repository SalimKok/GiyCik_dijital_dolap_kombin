import 'package:flutter/material.dart';

class ClothingCaptureScreen extends StatelessWidget {
  const ClothingCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kıyafet Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.style_rounded,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Yapay zekâ ile kıyafet analizi',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kıyafetin fotoğrafını yükle; kategori, renk, mevsim ve kombin '
                        'önerileri otomatik analiz edilsin.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                _showComingSoon(context);
              },
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text('Galeriden fotoğraf seç'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                _showComingSoon(context);
              },
              icon: const Icon(Icons.photo_camera_rounded),
              label: const Text('Kamerayla çek'),
            ),
            const Spacer(),
            Text(
              'Not: Şu an sadece arayüz hazır. Bir sonraki adımda Python tabanlı '
                  'AI servisine entegrasyon yapacağız.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fotoğraf analizi entegrasyonu bir sonraki adımda eklenecek.'),
      ),
    );
  }
}