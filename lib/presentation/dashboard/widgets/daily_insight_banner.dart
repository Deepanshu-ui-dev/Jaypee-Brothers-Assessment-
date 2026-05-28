import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/transaction_provider.dart';

class DailyInsightBanner extends ConsumerWidget {
  const DailyInsightBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(weeklyInsightProvider);

    return GestureDetector(
      onTap: () => context.go('/analytics'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: context.colors.insightBannerBg,
          borderRadius: BorderRadius.circular(20),
        ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: insight.when(
              data: (data) => Text(
                data.isPositive ? '🎯' : '⚠️',
                style: const TextStyle(fontSize: 32),
              ),
              loading: () => const Text('💡', style: TextStyle(fontSize: 32)),
              error: (_, __) =>
                  const Text('💡', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Insight',
                  style: context.textStyles.subheading
                      .copyWith(color: context.colors.insightBannerText),
                ),
                const SizedBox(height: 2),
                insight.when(
                  data: (data) => Text(
                    data.text,
                    style: context.textStyles.caption.copyWith(
                      color: context.colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  loading: () => Text(
                    'Calculating your spending patterns…',
                    style: context.textStyles.caption.copyWith(
                      color: context.colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  error: (_, __) => Text(
                    'Add transactions to see your weekly insights',
                    style: context.textStyles.caption.copyWith(
                      color: context.colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: context.colors.textMuted),
        ],
      ),
    ),
    );
  }
}
