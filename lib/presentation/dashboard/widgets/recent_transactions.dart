import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';
import '../../transactions/add_edit_transaction_sheet.dart';

class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentTransactionsProvider);

    return recent.when(
      data: (txns) {
        if (txns.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.receipt_long_rounded,
                    size: 36, color: context.colors.textMuted.withAlpha(100)),
                const SizedBox(height: 8),
                Text('No transactions yet', style: context.textStyles.heading),
                const SizedBox(height: 4),
                Text('Add your first transaction to get started',
                    style: context.textStyles.caption, textAlign: TextAlign.center),
              ],
            ),
          );
        }

        return Column(
          children: txns.map((txn) => _TxnRow(txn: txn)).toList(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn});
  final TransactionModel txn;

  @override
  Widget build(BuildContext context) {
    // Generate soft tint color based on category name lengths for visual variance, or standard if specific mapping exists
    Color _getIconTint(AppColors c) {
      if (txn.categoryName.toLowerCase().contains('food')) return c.categoryFood;
      if (txn.categoryName.toLowerCase().contains('transport')) return c.categoryTransport;
      if (txn.categoryName.toLowerCase().contains('grocer')) return c.categoryGrocery;
      if (txn.categoryName.toLowerCase().contains('shop')) return c.categoryShopping;
      return txn.isIncome ? c.incomeGreen : c.categoryOthers;
    }

    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: context.colors.surface,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => AddEditTransactionSheet(existing: txn),
      ),
      child: Container(
        height: 64,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.divider, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _getIconTint(context.colors).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                txn.isIncome ? Icons.arrow_downward_rounded : Icons.receipt_long_rounded,
                size: 20,
                color: _getIconTint(context.colors),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    txn.note.isNotEmpty ? txn.note : txn.categoryName, 
                    style: context.textStyles.bodyMedium.copyWith(fontSize: 14),
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${txn.date.shortDate} · ${txn.categoryName}', 
                    style: context.textStyles.caption.copyWith(fontSize: 11),
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${txn.isIncome ? '' : '-'}${txn.amount.asCurrency}',
              style: context.textStyles.heading.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
