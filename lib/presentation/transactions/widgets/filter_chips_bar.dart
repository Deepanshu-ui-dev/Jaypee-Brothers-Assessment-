import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/transaction_provider.dart';

class FilterChipsBar extends ConsumerWidget {
  const FilterChipsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(txnFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Chip(
            label: 'All',
            isSelected: filter == TxnFilter.all,
            onTap: () => ref.read(txnFilterProvider.notifier).state = TxnFilter.all,
          ),
          const SizedBox(width: 6),
          _Chip(
            label: 'Income',
            isSelected: filter == TxnFilter.income,
            onTap: () => ref.read(txnFilterProvider.notifier).state = TxnFilter.income,
          ),
          const SizedBox(width: 6),
          _Chip(
            label: 'Expense',
            isSelected: filter == TxnFilter.expense,
            onTap: () => ref.read(txnFilterProvider.notifier).state = TxnFilter.expense,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.ink : context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.colors.ink : context.colors.divider.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: context.textStyles.label.copyWith(
            color: isSelected ? context.colors.onInk : context.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
