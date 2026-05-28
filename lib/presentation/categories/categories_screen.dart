import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/category_model.dart';
import '../../providers/category_provider.dart';
import 'add_category_sheet.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: context.colors.pageBg,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Categories', style: context.textStyles.appBarTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: context.colors.divider),
        ),
      ),
      body: cats.when(
        data: (categories) {
          final expenses = categories.where((c) => c.type == 'expense').toList();
          final incomes = categories.where((c) => c.type == 'income').toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              const _SectionHeader(title: 'Expense Categories'),
              const SizedBox(height: 10),
              _CategoryGrid(categories: expenses, ref: ref),
              const SizedBox(height: 20),
              const _SectionHeader(title: 'Income Categories'),
              const SizedBox(height: 10),
              _CategoryGrid(categories: incomes, ref: ref),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          backgroundColor: context.colors.surface,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
          builder: (_) => const AddCategorySheet(type: 'expense'),
        ),
        backgroundColor: context.colors.ink,
        foregroundColor: context.colors.onInk,
        elevation: 0,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title.toUpperCase(), style: context.textStyles.sectionHeader);
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories, required this.ref});
  final List<CategoryModel> categories;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (_, i) {
        final cat = categories[i];
        return GestureDetector(
          onLongPress: cat.isDefault
              ? null
              : () => _confirmDelete(context, cat),
          child: Column(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: cat.themedBgColor(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.colors.divider, width: 0.5),
                ),
                child: Icon(cat.icon, size: 22, color: cat.color),
              ),
              const SizedBox(height: 5),
              Text(
                cat.name,
                style: context.textStyles.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, CategoryModel cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete "${cat.name}"?', style: context.textStyles.heading),
        content: Text('This will not delete existing transactions.',
            style: context.textStyles.caption),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.colors.expenseRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(categoryNotifierProvider.notifier).deleteCategory(cat.id);
    }
  }
}
