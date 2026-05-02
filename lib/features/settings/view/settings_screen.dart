import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/theme/theme_provider.dart';
import 'package:gircik/features/subscription/viewmodel/subscription_viewmodel.dart';
import 'package:gircik/features/subscription/view/pro_paywall_screen.dart';
import 'package:gircik/data/models/subscription.dart';
import 'package:gircik/features/settings/viewmodel/settings_viewmodel.dart';
import 'package:gircik/features/auth/repository/auth_repository.dart';
import 'package:gircik/core/providers/navigation_provider.dart';

import '../../../core/app_start_screen.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

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
          _buildProStatusCard(context, ref, theme, subscription),
          const SizedBox(height: 24),

          // ── Görünüm ──
          _SectionHeader(title: 'Görünüm', theme: theme),
          _SettingsCard(
            children: [
              _SettingsTile(
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
          _SectionHeader(title: 'Bildirimler', theme: theme),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.notifications_rounded,
                iconColor: Colors.blue,
                title: 'Genel Bildirimler',
                subtitle: 'Uygulama bildirimlerini yönet',
                trailing: Switch(
                  value: settings.notificationsEnabled, 
                  onChanged: settingsNotifier.setNotificationsEnabled,
                ),
              ),
              const _SettingsDivider(),
              _SettingsTile(
                icon: Icons.local_laundry_service_rounded,
                iconColor: Colors.teal,
                title: 'Yıkama Hatırlatıcısı',
                subtitle: 'Kullanım sınırı dolunca bildir',
                trailing: Switch(
                  value: settings.laundryReminderEnabled, 
                  onChanged: settingsNotifier.setLaundryReminderEnabled,
                ),
              ),
              const _SettingsDivider(),
              _SettingsTile(
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
          _SectionHeader(title: 'Gardırop Ayarları', theme: theme),
          _SettingsCard(
            children: [
              _SettingsTile(
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
                onTap: () => _showUsageLimitDialog(context, ref, settings.defaultUsageLimit),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Hesap ──
          _SectionHeader(title: 'Hesap', theme: theme),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.person_rounded,
                iconColor: Colors.green,
                title: 'Profil Bilgileri',
                subtitle: 'Ad ve e-posta adresini güncelle',
                trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                onTap: () => _showProfileDialog(context, ref),
              ),
              const _SettingsDivider(),
              _SettingsTile(
                icon: Icons.lock_rounded,
                iconColor: Colors.blueGrey,
                title: 'Şifre Değiştir',
                subtitle: 'Hesap güvenliğini güncelle',
                trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                onTap: () => _showChangePasswordDialog(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Veri ──
          _SectionHeader(title: 'Veri Yönetimi', theme: theme),
          _SettingsCard(
            children: [
              _SettingsTile(
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
          _SectionHeader(title: 'Hakkında', theme: theme),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.info_rounded,
                iconColor: Colors.grey,
                title: 'Uygulama Sürümü',
                subtitle: 'GiyÇık v1.0.0',
              ),
              const _SettingsDivider(),
              _SettingsTile(
                icon: Icons.description_rounded,
                iconColor: Colors.grey,
                title: 'Gizlilik Politikası',
                trailing: Icon(Icons.open_in_new_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                onTap: () {},
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
                    onPressed: () => _showLogoutDialog(context, ref),
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
                  onPressed: () => _showDeleteAccountDialog(context, ref),
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

  void _showUsageLimitDialog(BuildContext context, WidgetRef ref, int currentLimit) {
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

  void _showProfileDialog(BuildContext context, WidgetRef ref) async {
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

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
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

  void _showCancelSubscriptionDialog(BuildContext context, WidgetRef ref) {
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

  Widget _buildProStatusCard(BuildContext context, WidgetRef ref, ThemeData theme, Subscription subscription) {
    if (subscription.isPro) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade600, Colors.orange.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GiyÇık Pro', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${subscription.planDisplayName} · Tüm özellikler aktif', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _showCancelSubscriptionDialog(context, ref),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                ),
                child: const Text('Aboneliği İptal Et'),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: theme.cardTheme.shadowColor ?? theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.workspace_premium_rounded, color: Colors.amber.shade700),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ücretsiz Plan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('Pro ile sınırsız kullan', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _UsageBar(label: 'Kıyafet', current: subscription.clothingItemCount, max: FreeLimits.maxClothingItems, theme: theme),
          const SizedBox(height: 8),
          _UsageBar(label: 'Kombin', current: subscription.outfitCount, max: FreeLimits.maxOutfits, theme: theme),
          const SizedBox(height: 8),
          _UsageBar(label: 'AI Öneri', current: subscription.aiUsagesToday, max: FreeLimits.maxTotalAIRecommendations, theme: theme),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProPaywallScreen())),
              icon: const Icon(Icons.star_rounded, size: 18),
              label: const Text('Pro\'ya Yükselt'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final ThemeData theme;

  const _UsageBar({required this.label, required this.current, required this.max, required this.theme});

  @override
  Widget build(BuildContext context) {
    final ratio = (current / max).clamp(0.0, 1.0);
    final isNearLimit = ratio >= 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
            Text('$current / $max', style: theme.textTheme.bodySmall?.copyWith(
              color: isNearLimit ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
              fontWeight: isNearLimit ? FontWeight.bold : FontWeight.normal,
            )),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(
              isNearLimit ? theme.colorScheme.error : Colors.amber.shade600,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Yardımcı Widget'lar ──

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontSize: 13,
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.cardTheme.shadowColor ?? theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
      ),
    );
  }
}
