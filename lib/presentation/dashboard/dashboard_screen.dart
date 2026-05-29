import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/breakpoints.dart';
import '../../providers/auth_provider.dart';
import 'widgets/balance_card.dart';
import 'widgets/daily_insight_banner.dart';
import 'widgets/browse_categories.dart';
import 'widgets/recent_transactions.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (context.isDesktop) {
      return _buildDesktop(context, user);
    }
    return _buildMobile(context, user);
  }

  // ── Desktop two-column layout ──────────────────────────────────────────
  Widget _buildDesktop(BuildContext context, dynamic user) {
    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top header bar
            _DesktopHeader(user: user),
            const Divider(height: 1),
            // Body
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column — Balance + Insight
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 24, 14, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Overview',
                              style: context.textStyles.heading
                                  .copyWith(fontSize: 20)),
                          const SizedBox(height: 16),
                          const BalanceCard(),
                          const SizedBox(height: 16),
                          const DailyInsightBanner(),
                          const SizedBox(height: 32),
                          Text('Browse Categories',
                              style: context.textStyles.subheading),
                          const SizedBox(height: 16),
                          const BrowseCategories(),
                        ],
                      ),
                    ),
                  ),
                  // Divider
                  Container(width: 1, color: context.colors.divider),
                  // Right column — Transactions
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(14, 24, 28, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Recent Transactions',
                                  style: context.textStyles.heading
                                      .copyWith(fontSize: 20)),
                              TextButton(
                                onPressed: () => context.go('/transactions'),
                                style: TextButton.styleFrom(
                                  foregroundColor: context.colors.primary,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text('See All',
                                    style: context.textStyles.bodyMedium
                                        .copyWith(
                                            color: context.colors.primary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const RecentTransactions(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mobile layout (original) ───────────────────────────────────────────
  Widget _buildMobile(BuildContext context, dynamic user) {
    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/settings'),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: context.colors.primary
                                  .withValues(alpha: 0.2),
                              width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          user?.initials ?? 'U',
                          style: context.textStyles.heading.copyWith(
                            color: context.colors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello 👋',
                              style: context.textStyles.caption.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(
                            user != null
                                ? user.name.split(' ').first
                                : 'User',
                            style: context.textStyles.heading
                                .copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/notifications'),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.surface,
                          border: Border.all(
                              color: context.colors.divider, width: 0.5),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.notifications_none_rounded,
                                color: context.colors.textPrimary, size: 22),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: context.colors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: context.colors.surface,
                                      width: 1.5),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const BalanceCard(),
                const SizedBox(height: 16),
                const DailyInsightBanner(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Browse Category',
                        style: context.textStyles.subheading),
                    Row(
                      children: [
                        Container(
                            width: 12,
                            height: 4,
                            decoration: BoxDecoration(
                                color: context.colors.primary,
                                borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 4),
                        Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                                color: context.colors.textMuted.withAlpha(50),
                                borderRadius: BorderRadius.circular(2))),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                const BrowseCategories(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Transactions',
                        style: context.textStyles.subheading),
                    TextButton(
                      onPressed: () => context.go('/transactions'),
                      style: TextButton.styleFrom(
                        foregroundColor: context.colors.primary,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('See All',
                          style: context.textStyles.bodyMedium
                              .copyWith(color: context.colors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const RecentTransactions(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Desktop top header ─────────────────────────────────────────────────────

class _DesktopHeader extends ConsumerWidget {
  const _DesktopHeader({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello 👋, ${user?.name?.split(' ')?.first ?? 'there'}',
                  style: context.textStyles.heading.copyWith(fontSize: 20)),
              Text('Here\'s your financial snapshot',
                  style: context.textStyles.caption),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/notifications'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.divider),
              ),
              child: Icon(Icons.notifications_none_rounded,
                  color: context.colors.textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.go('/settings'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.primary.withAlpha(12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: context.colors.primary.withAlpha(40)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: context.colors.balanceCardGradient,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      user?.initials ?? 'U',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(user?.name?.split(' ')?.first ?? 'User',
                      style: context.textStyles.bodyMedium.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
