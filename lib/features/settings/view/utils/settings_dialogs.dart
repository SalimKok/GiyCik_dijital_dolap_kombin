import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/auth/repository/auth_repository.dart';
import 'package:gircik/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:gircik/features/settings/viewmodel/settings_viewmodel.dart';
import 'package:gircik/features/subscription/viewmodel/subscription_viewmodel.dart';
import 'package:gircik/core/app_start_screen.dart';

class SettingsDialogs {
  static void showUsageLimitDialog(BuildContext context, WidgetRef ref, int currentLimit) {
    final controller = TextEditingController(text: currentLimit.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanım Sınırı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kıyafetler kaç kez giyildikten sonra yıkama listesine eklensin?',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Kullanım Sayısı',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixText: 'kez',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          FilledButton(
            onPressed: () {
              final newVal = int.tryParse(controller.text);
              if (newVal != null && newVal > 0) {
                ref.read(settingsViewModelProvider.notifier).setDefaultUsageLimit(newVal);
                Navigator.pop(context);
              }
            },
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }

  static void showProfileDialog(BuildContext context, WidgetRef ref) async {
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil Bilgileri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Ad Soyad'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-posta'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(authRepositoryProvider).updateProfile(
                  name: nameController.text,
                  email: emailController.text,
                );
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  static void showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: TextField(
          controller: passController,
          decoration: const InputDecoration(labelText: 'Yeni Şifre'),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(authRepositoryProvider).updateProfile(password: passController.text);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  static void showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabından çıkış yapmak istediğine emin misin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          FilledButton(
            onPressed: () async {
              await ref.read(authViewModelProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AppStartScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  static void showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil', style: TextStyle(color: Colors.red)),
        content: const Text('Bu işlem geri alınamaz. Tüm verilerin kalıcı olarak silinecektir. Onaylıyor musun?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(authViewModelProvider.notifier).deleteAccount();
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AppStartScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Silmeyi Onayla'),
          ),
        ],
      ),
    );
  }

  static void showCancelSubscriptionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aboneliği İptal Et'),
        content: const Text('Pro aboneliğinizi iptal etmek istediğinize emin misiniz? Sınırsız özelliklere erişiminizi kaybedeceksiniz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(subscriptionProvider.notifier).cancelSubscription();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Aboneliğiniz başarıyla iptal edildi.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Evet, İptal Et'),
          ),
        ],
      ),
    );
  }
}
