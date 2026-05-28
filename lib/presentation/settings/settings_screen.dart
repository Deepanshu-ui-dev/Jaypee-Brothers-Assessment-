import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/num_extensions.dart';
import '../../data/services/export_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/biometric_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final income = ref.watch(totalIncomeProvider).valueOrNull ?? 0;
    final expense = ref.watch(totalExpenseProvider).valueOrNull ?? 0;
    final isDark = ref.watch(themeProvider);
    final reminderEnabled = ref.watch(reminderProvider);
    final biometricState = ref.watch(biometricProvider);

    final totalSaved = (income - expense).clamp(0.0, double.infinity);
    final currentStreak = ref.watch(streakProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.canPop() ? context.pop() : context.go('/'),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: context.colors.surface, shape: BoxShape.circle, border: Border.all(color: context.colors.divider)),
                    child: const Icon(Icons.arrow_back_rounded, size: 20),
                  ),
                ),
                Text('My Profile', style: context.textStyles.heading.copyWith(fontSize: 18)),
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: context.colors.surface, shape: BoxShape.circle, border: Border.all(color: context.colors.divider)),
                    child: const Icon(Icons.edit_rounded, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Avatar
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withAlpha(20),
                      shape: BoxShape.circle,
                      border: Border.all(color: context.colors.primary.withAlpha(40), width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      user?.initials ?? 'U',
                      style: context.textStyles.heading.copyWith(fontSize: 28, color: context.colors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(user?.name ?? 'User', style: context.textStyles.heading.copyWith(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text('@${user?.name.split(' ').first.toLowerCase() ?? 'user'}', style: context.textStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Streak Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text('Current Streak', style: context.textStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('$currentStreak Days', style: context.textStyles.heading.copyWith(fontSize: 18)),
                        const SizedBox(height: 4),
                        Text('Great job!', style: context.textStyles.label.copyWith(color: context.colors.primary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('💰', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text('Total Saved', style: context.textStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(totalSaved.asCurrency, style: context.textStyles.heading.copyWith(fontSize: 18)),
                        const SizedBox(height: 4),
                        Text('Awesome!', style: context.textStyles.label.copyWith(color: context.colors.primary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Options List
            Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.person_outline_rounded,
                    title: 'Personal Information',
                    onTap: () => context.push('/profile'),
                  ),
                  const Divider(height: 1, indent: 60),
                  _SettingsToggleRow(
                    icon: Icons.dark_mode_outlined,
                    title: 'Appearance (Dark Mode)',
                    value: isDark,
                    onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
                  ),
                  const Divider(height: 1, indent: 60),
                  _SettingsToggleRow(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notification Settings',
                    value: reminderEnabled,
                    onChanged: (_) => ref.read(reminderProvider.notifier).toggle(),
                  ),
                  const Divider(height: 1, indent: 60),
                  _SettingsToggleRow(
                    icon: Icons.security_rounded,
                    title: 'Biometric Security',
                    value: biometricState.isEnabled,
                    onChanged: biometricState.isAvailable
                        ? (_) async => await ref.read(biometricProvider.notifier).toggle()
                        : (_) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not available')));
                          },
                  ),
                  const Divider(height: 1, indent: 60),
                  _SettingsRow(
                    icon: Icons.cloud_download_outlined,
                    title: 'Export Data CSV',
                    onTap: () async {
                      final txns = ref.read(transactionsProvider).valueOrNull ?? [];
                      if (txns.isEmpty) return;
                      await ExportService.exportTransactionsCsv(txns);
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  _SettingsRow(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    iconColor: context.colors.expenseRed,
                    textColor: context.colors.expenseRed,
                    hideArrow: true,
                    onTap: () async {
                      await ref.read(authNotifierProvider.notifier).signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120), // Bottom padding for nav orb
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.hideArrow = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool hideArrow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: context.colors.surfaceSubtle, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: iconColor ?? context.colors.textPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: context.textStyles.bodyMedium.copyWith(color: textColor))),
            if (!hideArrow) Icon(Icons.chevron_right_rounded, color: context.colors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: context.colors.surfaceSubtle, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: context.colors.textPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: context.textStyles.bodyMedium)),
          Transform.scale(
            scale: 0.8,
            child: CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
