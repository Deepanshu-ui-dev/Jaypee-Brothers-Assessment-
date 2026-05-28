import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/num_extensions.dart';
import '../../providers/transaction_provider.dart';
import 'widgets/category_breakdown_list.dart';
import 'widgets/monthly_bar_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentExpense = ref.watch(currentMonthExpenseProvider);
    final previousExpense = ref.watch(previousMonthExpenseProvider);
    final txnCount = ref.watch(currentMonthTxnCountProvider);
    final prevTxnCount = ref.watch(previousMonthTxnCountProvider);

    final now = DateTime.now();
    final dayOfMonth = now.day;
    final monthName = _monthName(now.month);

    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          children: [
            // ── Header ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Insights',
                  style: context.textStyles.displayAmount
                      .copyWith(fontSize: 24, fontWeight: FontWeight.normal),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    border: Border.all(
                        color: context.colors.primary.withAlpha(50)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_rounded,
                          size: 14, color: context.colors.primary),
                      const SizedBox(width: 6),
                      Text(monthName,
                          style: context.textStyles.bodyMedium
                              .copyWith(color: context.colors.primary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Stat Pills ────────────────────────────────────────────
            Row(
              children: [
                // Total Expenses
                Expanded(
                  child: currentExpense.when(
                    data: (expense) {
                      final prevExp = previousExpense.valueOrNull ?? 0;
                      final vsLabel = _comparisonLabel(expense, prevExp, isPct: true);
                      final isDown = expense <= prevExp;
                      return _StatPill(
                        title: 'This Month',
                        value: expense.asCurrency,
                        subtitle: vsLabel,
                        icon: Icons.credit_card_rounded,
                        iconTint: context.colors.primary,
                        subtitlePositive: isDown,
                      );
                    },
                    loading: () => _StatPill(
                      title: 'This Month',
                      value: '—',
                      subtitle: 'Loading…',
                      icon: Icons.credit_card_rounded,
                      iconTint: context.colors.primary,
                    ),
                    error: (_, __) => _StatPill(
                      title: 'This Month',
                      value: '—',
                      subtitle: 'Error',
                      icon: Icons.credit_card_rounded,
                      iconTint: context.colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Daily Average
                Expanded(
                  child: currentExpense.when(
                    data: (expense) {
                      final prevExp = previousExpense.valueOrNull ?? 0;
                      final dailyAvg = dayOfMonth > 0 ? expense / dayOfMonth : 0.0;
                      final prevDays = _daysInPreviousMonth(now);
                      final prevDailyAvg = prevDays > 0 ? prevExp / prevDays : 0.0;
                      final vsLabel = _comparisonLabel(dailyAvg, prevDailyAvg, isPct: true);
                      return _StatPill(
                        title: 'Daily Avg.',
                        value: dailyAvg.asCurrency,
                        subtitle: vsLabel,
                        icon: Icons.access_time_rounded,
                        iconTint: context.colors.categoryShopping,
                        subtitlePositive: dailyAvg <= prevDailyAvg,
                      );
                    },
                    loading: () => _StatPill(
                      title: 'Daily Avg.',
                      value: '—',
                      subtitle: 'Loading…',
                      icon: Icons.access_time_rounded,
                      iconTint: context.colors.categoryShopping,
                    ),
                    error: (_, __) => _StatPill(
                      title: 'Daily Avg.',
                      value: '—',
                      subtitle: 'Error',
                      icon: Icons.access_time_rounded,
                      iconTint: context.colors.categoryShopping,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Entries count
                Expanded(
                  child: txnCount.when(
                    data: (count) {
                      final prevCount = prevTxnCount.valueOrNull ?? 0;
                      final diff = count - prevCount;
                      final sign = diff >= 0 ? '↑' : '↓';
                      final vsLabel =
                          diff == 0 ? 'Same as last month' : '$sign ${diff.abs()} vs last';
                      return _StatPill(
                        title: 'Entries',
                        value: '$count',
                        subtitle: vsLabel,
                        icon: Icons.list_alt_rounded,
                        iconTint: context.colors.categoryData,
                        subtitlePositive: diff >= 0,
                      );
                    },
                    loading: () => _StatPill(
                      title: 'Entries',
                      value: '—',
                      subtitle: 'Loading…',
                      icon: Icons.list_alt_rounded,
                      iconTint: context.colors.categoryData,
                    ),
                    error: (_, __) => _StatPill(
                      title: 'Entries',
                      value: '—',
                      subtitle: 'Error',
                      icon: Icons.list_alt_rounded,
                      iconTint: context.colors.categoryData,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Spending Breakdown ─────────────────────────────────────
            Text('Spending Breakdown', style: context.textStyles.subheading),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ],
              ),
              child: const CategoryBreakdownList(),
            ),
            const SizedBox(height: 32),

            // ── Spending Trend ─────────────────────────────────────────
            Text('Spending Trend (6 months)', style: context.textStyles.subheading),
            const SizedBox(height: 8),
            // Legend row
            Row(
              children: [
                _Legend(color: context.colors.ink, label: 'Income'),
                const SizedBox(width: 16),
                _Legend(color: context.colors.divider.withAlpha(200), label: 'Expense'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ],
              ),
              child: const MonthlyBarChart(),
            ),
            const SizedBox(height: 32),

            // ── Month Summary Card ─────────────────────────────────────
            currentExpense.when(
              data: (expense) {
                final income = ref.watch(totalIncomeProvider).valueOrNull ?? 0;
                final prevExp = previousExpense.valueOrNull ?? 0;
                final expDiff = expense - prevExp;
                final expSign = expDiff < 0 ? '↓' : '↑';
                final expPct = prevExp > 0
                    ? '$expSign ${((expDiff.abs() / prevExp) * 100).toStringAsFixed(1)}%'
                    : '—';
                return _MonthSummaryCard(
                  monthName: monthName,
                  income: income,
                  expense: expense,
                  expVsPrev: expPct,
                  expIsDown: expDiff < 0,
                  daysElapsed: dayOfMonth,
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month];
  }

  int _daysInPreviousMonth(DateTime now) {
    final prev = DateTime(now.year, now.month, 0); // last day of prev month
    return prev.day;
  }

  String _comparisonLabel(double current, double previous,
      {bool isPct = false}) {
    if (previous <= 0) return '—';
    final diff = current - previous;
    if (diff == 0) return 'Same as last month';
    final pct = ((diff.abs() / previous) * 100).toStringAsFixed(0);
    final sign = diff < 0 ? '↓' : '↑';
    return '$sign $pct% vs last month';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconTint,
    this.subtitlePositive = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconTint;
  final bool subtitlePositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: context.colors.ink.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: context.textStyles.label
                  .copyWith(fontSize: 10, color: context.colors.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: context.textStyles.heading.copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: context.textStyles.label.copyWith(
              fontSize: 9,
              color: subtitlePositive
                  ? context.colors.primary
                  : context.colors.expenseRed,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconTint.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: iconTint),
          )
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(label,
            style: context.textStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _MonthSummaryCard extends StatelessWidget {
  const _MonthSummaryCard({
    required this.monthName,
    required this.income,
    required this.expense,
    required this.expVsPrev,
    required this.expIsDown,
    required this.daysElapsed,
  });

  final String monthName;
  final double income;
  final double expense;
  final String expVsPrev;
  final bool expIsDown;
  final int daysElapsed;

  @override
  Widget build(BuildContext context) {
    final net = income - expense;
    final netPositive = net >= 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: context.colors.ink.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$monthName Summary',
                  style: context.textStyles.subheading),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Day $daysElapsed',
                    style: context.textStyles.label
                        .copyWith(color: context.colors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Income',
                  value: income.asCurrency,
                  icon: Icons.arrow_downward_rounded,
                  iconColor: context.colors.primary,
                ),
              ),
              Container(
                  width: 1,
                  height: 40,
                  color: context.colors.divider),
              Expanded(
                child: _SummaryItem(
                  label: 'Expenses',
                  value: expense.asCurrency,
                  icon: Icons.arrow_upward_rounded,
                  iconColor: context.colors.expenseRed,
                  subtitle: expVsPrev,
                  subtitlePositive: expIsDown,
                ),
              ),
              Container(
                  width: 1,
                  height: 40,
                  color: context.colors.divider),
              Expanded(
                child: _SummaryItem(
                  label: 'Net',
                  value: net.abs().asCurrency,
                  icon: netPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  iconColor: netPositive
                      ? context.colors.primary
                      : context.colors.expenseRed,
                  prefix: netPositive ? '+' : '-',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.subtitle,
    this.subtitlePositive = true,
    this.prefix = '',
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? subtitle;
  final bool subtitlePositive;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 4),
              Text(label,
                  style: context.textStyles.label.copyWith(
                      fontSize: 10,
                      color: context.colors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Text('$prefix$value',
              style: context.textStyles.heading.copyWith(fontSize: 13)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: context.textStyles.label.copyWith(
                fontSize: 9,
                color: subtitlePositive
                    ? context.colors.primary
                    : context.colors.expenseRed,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
