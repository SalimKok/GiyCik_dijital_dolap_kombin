import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/theme/theme_provider.dart';
import 'package:gircik/features/subscription/viewmodel/subscription_viewmodel.dart';
import 'package:gircik/features/subscription/view/pro_paywall_screen.dart';
import 'package:gircik/data/models/subscription.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // ── Pro Durum Kartı ──
          _buildProStatusCard(context, theme, subscription),
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
                title: 'Bildirimler',
                subtitle: 'Uygulama bildirimlerini yönet',
                trailing: Switch(value: true, onChanged: (_) {}),
              ),
              const _SettingsDivider(),
              _SettingsTile(
                icon: Icons.local_laundry_service_rounded,
                iconColor: Colors.teal,
                title: 'Yıkama Hatırlatıcısı',
                subtitle: 'Kullanım sınırı dolunca bildir',
                trailing: Switch(value: true, onChanged: (_) {}),
              ),
              const _SettingsDivider(),
              _SettingsTile(
                icon: Icons.calendar_month_rounded,
                iconColor: Colors.orange,
                title: 'Etkinlik Hatırlatıcısı',
                subtitle: 'Yaklaşan etkinliklerden önce bildir',
                trailing: Switch(value: true, onChanged: (_) {}),
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
                    '3 kez',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                onTap: () {},
              ),
              const _SettingsDivider(),
              _SettingsTile(
                icon: Icons.category_rounded,
                iconColor: Colors.indigo,
                title: 'Kategorileri Düzenle',
                subtitle: 'Kıyafet kategorilerini özelleştir',
                trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                onTap: () {},
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
                subtitle: 'Ad, e-posta ve fotoğraf',
                trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                onTap: () {},
              ),
              const _SettingsDivider(),
              _SettingsTile(
                icon: Icons.lock_rounded,
                iconColor: Colors.blueGrey,
                title: 'Şifre Değiştir',
                subtitle: 'Hesap güvenliğini güncelle',
                trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Veri ──
          _SectionHeader(title: 'Veri Yönetimi', theme: theme),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.cloud_upload_rounded,
                iconColor: Colors.cyan,
                title: 'Yedekleme',
                subtitle: 'Verilerini buluta yedekle',
                trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                onTap: () {},
              ),
              const _SettingsDivider(),
              _SettingsTile(
                icon: Icons.delete_sweep_rounded,
                iconColor: Colors.red,
                title: 'Önbelleği Temizle',
                subtitle: 'Geçici dosyaları sil',
                trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                onTap: () {},
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
              const _SettingsDivider(),
              _SettingsTile(
                icon: Icons.gavel_rounded,
                iconColor: Colors.grey,
                title: 'Kullanım Koşulları',
                trailing: Icon(Icons.open_in_new_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Çıkış ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Çıkış Yap'),
                    content: const Text('Hesabından çıkış yapmak istediğine emin misin?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('İptal'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Gerçek çıkış mantığı eklenecek
                        },
                        child: const Text('Çıkış Yap'),
                      ),
                    ],
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Çıkış Yap'),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProStatusCard(BuildContext context, ThemeData theme, Subscription subscription) {
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
        child: Row(
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
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
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
          _UsageBar(label: 'AI Öneri', current: subscription.aiUsagesToday, max: FreeLimits.maxAIRecommendationsPerDay, theme: theme),
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
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.04),
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
