import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../providers/transaction_provider.dart';

class CategoryBars extends ConsumerWidget {
  const CategoryBars({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = ref.watch(expenseByCategoryProvider);
    final totalExpense = ref.watch(totalExpenseProvider);

    return breakdown.when(
      data: (map) {
        if (map.isEmpty) return const SizedBox.shrink();
        final top3 = map.entries.take(3).toList();
        final total = totalExpense.valueOrNull ?? 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending by Category', style: context.textStyles.subheading),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.colors.divider, width: 0.5),
              ),
              child: Column(
                children: List.generate(top3.length, (i) {
                  final entry = top3[i];
                  final frac = total > 0 ? (entry.value / total) : 0.0;
                  return Padding(
                    padding: EdgeInsets.only(bottom: i < top3.length - 1 ? 12 : 0),
                    child: _CategoryRow(
                      name: entry.key,
                      amount: entry.value,
                      fraction: frac.clampedProgress,
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.name,
    required this.amount,
    required this.fraction,
  });

  final String name;
  final double amount;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: context.textStyles.bodyMedium),
            Text(amount.asCurrency,
                style: context.textStyles.cardAmount.copyWith(
                    color: context.colors.expenseRed)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: context.colors.surfaceSubtle,
            valueColor: AlwaysStoppedAnimation(context.colors.ink),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
