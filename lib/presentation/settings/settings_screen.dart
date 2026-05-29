import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/num_extensions.dart';
import '../../core/utils/breakpoints.dart';
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
    final isDark = ref.watch(themeProvider);
    final reminderEnabled = ref.watch(reminderProvider);
    final biometricState = ref.watch(biometricProvider);
    final currentStreak = ref.watch(streakProvider).valueOrNull ?? 0;
    final entriesThisMonth = ref.watch(currentMonthTxnCountProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.isDesktop ? 720 : double.infinity),
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

            // ── Avatar + name + email ─────────────────────────────────
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 88, height: 88,
                        decoration: BoxDecoration(
                          gradient: context.colors.balanceCardGradient,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.colors.primary.withAlpha(60), width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          user?.initials ?? 'U',
                          style: context.textStyles.heading.copyWith(fontSize: 32, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: context.colors.pageBg, width: 2),
                            ),
                            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(user?.name ?? 'User',
                      style: context.textStyles.heading.copyWith(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '',
                      style: context.textStyles.caption),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => context.push('/profile'),
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text('Edit Profile'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.textPrimary,
                          side: BorderSide(color: context.colors.divider),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          textStyle: context.textStyles.label,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.colors.divider),
                        ),
                        child: Icon(Icons.settings_outlined,
                            size: 18, color: context.colors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Streak + Entries cards ────────────────────────────────
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
                        Row(children: [
                          const Text('🔥', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text('Streak', style: context.textStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 10),
                        Text('$currentStreak',
                            style: context.textStyles.heading.copyWith(fontSize: 22)),
                        Text('days', style: context.textStyles.label.copyWith(color: context.colors.primary)),
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
                        Row(children: [
                          Icon(Icons.receipt_long_rounded, size: 20, color: context.colors.categoryTransport),
                          const SizedBox(width: 8),
                          Text('Entries', style: context.textStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 10),
                        Text('$entriesThisMonth',
                            style: context.textStyles.heading.copyWith(fontSize: 22)),
                        Text('this month', style: context.textStyles.label.copyWith(color: context.colors.categoryTransport)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Main menu ─────────────────────────────────────────────
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
                    title: 'Personal Summary',
                    onTap: () => context.push('/profile'),
                  ),
                  Divider(height: 0.5, indent: 60, color: context.colors.divider),
                  _SettingsRow(
                    icon: Icons.tune_rounded,
                    title: 'App Behaviour Controls',
                    onTap: () {},
                    trailingWidget: _AppBehaviourControls(
                      isDark: isDark,
                      reminderEnabled: reminderEnabled,
                      biometricState: biometricState,
                      ref: ref,
                    ),
                  ),
                  Divider(height: 0.5, indent: 60, color: context.colors.divider),
                  _SettingsRow(
                    icon: Icons.cloud_download_outlined,
                    title: 'Export Data (CSV)',
                    onTap: () async {
                      final txns = ref.read(transactionsProvider).valueOrNull ?? [];
                      if (txns.isEmpty) return;
                      await ExportService.exportTransactionsCsv(txns);
                    },
                  ),
                  Divider(height: 0.5, indent: 60, color: context.colors.divider),
                  _SettingsRow(
                    icon: Icons.support_agent_rounded,
                    title: 'Support',
                    onTap: () {},
                  ),
                  Divider(height: 0.5, indent: 60, color: context.colors.divider),
                  _SettingsRow(
                    icon: Icons.info_outline_rounded,
                    title: 'About App',
                    onTap: () {},
                    trailingIcon: Icons.open_in_new_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Logout ────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.expenseRed.withAlpha(30)),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (context.mounted) context.go('/login');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.colors.expenseBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.power_settings_new_rounded,
                            size: 20, color: context.colors.expenseRed),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text('Logout',
                            style: context.textStyles.bodyMedium
                                .copyWith(color: context.colors.expenseRed, fontWeight: FontWeight.w700)),
                      ),
                      Icon(Icons.chevron_right_rounded, color: context.colors.expenseRed),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 120),
          ],
            ),
          ),
        ),
      ),
    );
  }
}

// A compact inline widget for App Behaviour Controls
class _AppBehaviourControls extends StatelessWidget {
  const _AppBehaviourControls({
    required this.isDark,
    required this.reminderEnabled,
    required this.biometricState,
    required this.ref,
  });
  final bool isDark;
  final bool reminderEnabled;
  final dynamic biometricState;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          _SettingsToggleRow(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            value: isDark,
            onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
          ),
          const SizedBox(height: 8),
          _SettingsToggleRow(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            value: reminderEnabled,
            onChanged: (_) => ref.read(reminderProvider.notifier).toggle(),
          ),
          const SizedBox(height: 8),
          _SettingsToggleRow(
            icon: Icons.security_rounded,
            title: 'Biometric Security',
            value: biometricState.isEnabled,
            onChanged: biometricState.isAvailable
                ? (_) async => await ref.read(biometricProvider.notifier).toggle()
                : (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Not available on this device')));
                  },
          ),
        ],
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
    this.trailingWidget,
    this.trailingIcon,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final Widget? trailingWidget;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: context.colors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 20, color: iconColor ?? context.colors.textPrimary),
                ),
                const SizedBox(width: 16),
                Expanded(
                    child: Text(title,
                        style: context.textStyles.bodyMedium.copyWith(color: textColor))),
                Icon(trailingIcon ?? Icons.chevron_right_rounded,
                    color: context.colors.textMuted, size: 20),
              ],
            ),
          ),
        ),
        if (trailingWidget != null) trailingWidget!,
      ],
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: context.colors.surfaceSubtle,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: context.colors.textPrimary),
        ),
        const SizedBox(width: 12),
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
    );
  }
}
