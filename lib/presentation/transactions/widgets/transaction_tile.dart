import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../data/models/transaction_model.dart';
import '../../transactions/add_edit_transaction_sheet.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.txn,
    required this.isLast,
    this.onDismissed,
    required this.categoryIcon,
    required this.categoryColor,
    required this.categoryBg,
  });

  final TransactionModel txn;
  final bool isLast;
  final VoidCallback? onDismissed;
  final IconData categoryIcon;
  final Color categoryColor;
  final Color categoryBg;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(txn.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: context.colors.expenseRed,
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 20),
      ),
      child: InkWell(
        onTap: () => showModalBottomSheet(
          context: context,
          backgroundColor: context.colors.surface,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
          builder: (_) => AddEditTransactionSheet(existing: txn),
        ),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(color: context.colors.divider, width: 0.5)),
          ),
          child: Row(
            children: [
              // Category icon tile
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: categoryBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(categoryIcon, size: 16, color: categoryColor),
              ),
              const SizedBox(width: 10),
              // Name + note
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(txn.categoryName, style: context.textStyles.bodyMedium),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryBg.withAlpha(150),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            txn.categoryName.toUpperCase(),
                            style: context.textStyles.caption.copyWith(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: categoryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (txn.note.isNotEmpty)
                      Text(txn.note, style: context.textStyles.caption,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              // Amount + date
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${txn.isIncome ? '+' : '-'}${txn.amount.asCurrency}',
                    style: context.textStyles.bodyMedium.copyWith(
                      color: txn.isIncome
                          ? context.colors.incomeGreen
                          : context.colors.expenseRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text('${txn.date.day.toString().padLeft(2, '0')} ${_month(txn.date.month)}',
                      style: context.textStyles.label),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}
