import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gircik/theme/theme_provider.dart';
import 'package:gircik/features/subscription/viewmodel/subscription_viewmodel.dart';
import 'package:gircik/features/settings/viewmodel/settings_viewmodel.dart';

import 'package:gircik/features/onboarding/view/welcome_screen.dart';

import 'package:gircik/features/settings/view/widgets/pro_status_card.dart';
import 'package:gircik/features/settings/view/widgets/settings_ui_components.dart';
import 'package:gircik/features/settings/view/utils/settings_dialogs.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final subscription = ref.watch(subscriptionProvider);
    final settings = ref.watch(settingsViewModelProvider);
    final settingsNotifier = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // ── Pro Durum Kartı ──
          ProStatusCard(subscription: subscription),
          const SizedBox(height: 24),

          // ── Görünüm ──
          const SectionHeader(title: 'Görünüm'),
          SettingsCard(
            children: [
              SettingsTile(
                icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                iconColor: Colors.amber.shade700,
                title: 'Koyu Tema',
                subtitle: isDark ? 'Koyu mod aktif' : 'Açık mod aktif',
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Bildirimler ──
          const SectionHeader(title: 'Bildirimler'),
          SettingsCard(
            children: [
              SettingsTile(
                icon: Icons.notifications_rounded,
                iconColor: Colors.blue,
                title: 'Genel Bildirimler',
                subtitle: 'Uygulama bildirimlerini yönet',
                trailing: Switch(
                  value: settings.notificationsEnabled, 
                  onChanged: settingsNotifier.setNotificationsEnabled,
                ),
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.local_laundry_service_rounded,
                iconColor: Colors.teal,
                title: 'Yıkama Hatırlatıcısı',
                subtitle: 'Kullanım sınırı dolunca bildir',
                trailing: Switch(
                  value: settings.laundryReminderEnabled, 
                  onChanged: settingsNotifier.setLaundryReminderEnabled,
                ),
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.calendar_month_rounded,
                iconColor: Colors.orange,
                title: 'Etkinlik Hatırlatıcısı',
                subtitle: 'Yaklaşan etkinliklerden önce bildir',
                trailing: Switch(
                  value: settings.eventReminderEnabled, 
                  onChanged: settingsNotifier.setEventReminderEnabled,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Gardırop ──
          const SectionHeader(title: 'Gardırop Ayarları'),
          SettingsCard(
            children: [
              SettingsTile(
                icon: Icons.repeat_rounded,
                iconColor: Colors.purple,
                title: 'Varsayılan Kullanım Sınırı',
                subtitle: 'Yeni eklenen kıyafetler için',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${settings.defaultUsageLimit} kez',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                onTap: () => SettingsDialogs.showUsageLimitDialog(context, ref, settings.defaultUsageLimit),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Hesap ──
          const SectionHeader(title: 'Hesap'),
          SettingsCard(
            children: [
              SettingsTile(
                icon: Icons.person_rounded,
                iconColor: Colors.green,
                title: 'Profil Bilgileri',
                subtitle: 'Ad ve e-posta adresini güncelle',
                trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                onTap: () => SettingsDialogs.showProfileDialog(context, ref),
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.lock_rounded,
                iconColor: Colors.blueGrey,
                title: 'Şifre Değiştir',
                subtitle: 'Hesap güvenliğini güncelle',
                trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                onTap: () => SettingsDialogs.showChangePasswordDialog(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Veri ──
          const SectionHeader(title: 'Veri Yönetimi'),
          SettingsCard(
            children: [
              SettingsTile(
                icon: Icons.delete_sweep_rounded,
                iconColor: Colors.red,
                title: 'Önbelleği Temizle',
                subtitle: 'Kombin önerilerini sıfırla',
                trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                onTap: () async {
                  await settingsNotifier.clearCache();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Önbellek temizlendi')),
                    );
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Hakkında ──
          const SectionHeader(title: 'Hakkında'),
          SettingsCard(
            children: [
              const SettingsTile(
                icon: Icons.info_rounded,
                iconColor: Colors.grey,
                title: 'Uygulama Sürümü',
                subtitle: 'GiyÇık v1.0.0',
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.description_rounded,
                iconColor: Colors.grey,
                title: 'Gizlilik Politikası',
                subtitle: 'Kişisel verilerin nasıl kullanıldığını öğren',
                trailing: Icon(Icons.open_in_new_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                onTap: () async {
                  final uri = Uri.parse('https://sites.google.com/view/giycikgizlilikpolitikasi/ana-sayfa');
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tarayıcı açılamadı.')),
                      );
                    }
                  }
                },
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.slideshow_rounded,
                iconColor: Colors.teal,
                title: 'Uygulama Tanıtımını İzle',
                trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WelcomeScreen(
                        onWelcomeDone: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Çıkış & Silme ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => SettingsDialogs.showLogoutDialog(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Çıkış Yap'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => SettingsDialogs.showDeleteAccountDialog(context, ref),
                  child: Text(
                    'Hesabımı Kalıcı Olarak Sil',
                    style: TextStyle(color: theme.colorScheme.error.withValues(alpha: 0.7), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
