import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/transaction_provider.dart';

class CategoryBreakdownList extends ConsumerWidget {
  const CategoryBreakdownList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = ref.watch(expenseByCategoryProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];

    return breakdown.when(
      data: (map) {
        if (map.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('No expense data', style: context.textStyles.caption),
            ),
          );
        }
        final total = map.values.fold(0.0, (a, b) => a + b);
        final entries = map.entries.toList();

        return Column(
          children: entries.map((entry) {
            final cat = categories.where((c) => c.name == entry.key).toList();
            final icon = cat.isNotEmpty ? cat.first.icon : Icons.more_horiz_rounded;
            final color = cat.isNotEmpty ? cat.first.color : context.colors.textSecondary;
            final bg = cat.isNotEmpty ? cat.first.bgColor : context.colors.tintGray;
            final fraction = total > 0 ? entry.value / total : 0.0;
            final pct = (fraction * 100).toStringAsFixed(1);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key, style: context.textStyles.bodyMedium),
                            Text('$pct%', style: context.textStyles.label),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fraction.clampedProgress,
                            backgroundColor: context.colors.surfaceSubtle,
                            valueColor: AlwaysStoppedAnimation(context.colors.ink),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                   Text(entry.value.asCurrency,
                       style: context.textStyles.bodyMedium.copyWith(
                         color: context.colors.expenseRed,
                         fontWeight: FontWeight.w600,
                       )),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
