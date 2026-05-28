import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/category_model.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/transaction_provider.dart';

class BrowseCategories extends ConsumerWidget {
  const BrowseCategories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(categoriesProvider);

    return cats.when(
      data: (categories) {
        // Show only expense categories, max 8
        final expenseCats = categories
            .where((c) => c.type == 'expense' || c.type == 'both')
            .take(8)
            .toList();

        if (expenseCats.isEmpty) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: expenseCats.map((cat) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _CategoryCard(
                  category: cat,
                  onTap: () {
                    // Set category filter and navigate to transactions
                    ref.read(txnCategoryFilterProvider.notifier).state = cat.name;
                    ref.read(txnFilterProvider.notifier).state = TxnFilter.expense;
                    context.go('/transactions');
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _SkeletonCard(),
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final CategoryModel category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.divider, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: context.colors.ink.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: category.themedBgColor(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category.icon, color: category.color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              category.name,
              style: context.textStyles.caption.copyWith(
                  fontWeight: FontWeight.w600, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 105,
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
