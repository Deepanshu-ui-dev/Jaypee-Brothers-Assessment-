import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/date_extensions.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import 'add_edit_transaction_sheet.dart';
import 'widgets/transaction_tile.dart';
import 'widgets/filter_chips_bar.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  bool _searchOpen = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = ref.watch(groupedTransactionsProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];

    return Scaffold(
      backgroundColor: context.colors.pageBg,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: _searchOpen
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: context.textStyles.body,
                decoration: InputDecoration(
                  hintText: 'Search transactions…',
                  hintStyle: context.textStyles.caption,
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (q) {
                  ref.read(txnSearchQueryProvider.notifier).state = q;
                },
              )
            : Text('Transactions', style: context.textStyles.appBarTitle),
        actions: [
          IconButton(
            icon: Icon(
              _searchOpen ? Icons.close_rounded : Icons.search_rounded,
              size: 20, color: context.colors.textPrimary,
            ),
            onPressed: () {
              setState(() => _searchOpen = !_searchOpen);
              if (!_searchOpen) {
                _searchCtrl.clear();
                ref.read(txnSearchQueryProvider.notifier).state = '';
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: context.colors.divider),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const FilterChipsBar(),
          const SizedBox(height: 12),
          Expanded(
            child: grouped.when(
              data: (groups) {
                if (groups.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_rounded,
                            size: 48, color: context.colors.textMuted),
                        const SizedBox(height: 12),
                        Text('No transactions found', style: context.textStyles.heading),
                        const SizedBox(height: 4),
                        Text('Try a different filter or add a new transaction',
                            style: context.textStyles.caption),
                      ],
                    ),
                  );
                }

                final sortedDates = groups.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: sortedDates.length,
                  itemBuilder: (_, i) {
                    final date = sortedDates[i];
                    final txns = groups[date]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                          child: Text(date.groupLabel.toUpperCase(),
                              style: context.textStyles.sectionHeader.copyWith(
                                letterSpacing: 0.5,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: context.colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.colors.divider.withValues(alpha: 0.5), width: 1),
                          ),
                          child: Column(
                            children: txns.asMap().entries.map((entry) {
                              final txn = entry.value;
                              final isLast = entry.key == txns.length - 1;

                              // Find category icon/color
                              final cat = categories.where((c) => c.id == txn.categoryId)
                                  .toList();
                              final icon = cat.isNotEmpty
                                  ? cat.first.icon
                                  : (txn.isIncome
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded);
                              final color = cat.isNotEmpty ? cat.first.color
                                  : (txn.isIncome ? context.colors.incomeGreen : context.colors.expenseRed);
                              final bg = cat.isNotEmpty ? cat.first.themedBgColor(context)
                                  : (txn.isIncome ? context.colors.incomeBg : context.colors.expenseBg);

                              return TransactionTile(
                                txn: txn,
                                isLast: isLast,
                                categoryIcon: icon,
                                categoryColor: color,
                                categoryBg: bg,
                                onDismissed: () async {
                                  final uid = ref.read(authRepositoryProvider).currentUser!.uid;
                                  await TransactionRepository().delete(uid, txn.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Transaction deleted')),
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
