import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../categories/add_category_sheet.dart';

class AddEditTransactionSheet extends ConsumerStatefulWidget {
  const AddEditTransactionSheet({super.key, this.existing});
  final TransactionModel? existing;

  @override
  ConsumerState<AddEditTransactionSheet> createState() =>
      _AddEditTransactionSheetState();
}

class _AddEditTransactionSheetState
    extends ConsumerState<AddEditTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _receiptCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  CategoryModel? _selectedCategory;
  DateTime _date = DateTime.now();
  String? _paymentMethod;
  bool _loading = false;

  final List<String> _paymentMethods = const [
    'Cash', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Wallet'
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _type = e.type;
      _amountCtrl.text = e.amount.toStringAsFixed(2);
      _noteCtrl.text = e.note;
      _date = e.date;
      _receiptCtrl.text = e.receiptNumber ?? '';
      _paymentMethod = e.paymentMethod;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _receiptCtrl.dispose();
    super.dispose();
  }

  void _addQuickAmount(double amount) {
    setState(() {
      final current = double.tryParse(_amountCtrl.text) ?? 0.0;
      _amountCtrl.text = (current + amount).toStringAsFixed(2);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null && widget.existing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    setState(() => _loading = true);
    final uid = ref.read(authRepositoryProvider).currentUser!.uid;
    final repo = TransactionRepository();
    final cat = _selectedCategory;

    final txn = TransactionModel(
      id: widget.existing?.id ?? '',
      type: _type,
      amount: double.parse(_amountCtrl.text.replaceAll(',', '')),
      categoryId: cat?.id ?? widget.existing?.categoryId ?? '',
      categoryName: cat?.name ?? widget.existing?.categoryName ?? 'Other',
      date: _date,
      note: _noteCtrl.text.trim(),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      receiptNumber: _receiptCtrl.text.trim().isEmpty ? null : _receiptCtrl.text.trim(),
      paymentMethod: _paymentMethod,
    );

    try {
      if (widget.existing != null) {
        await repo.update(uid, txn);
      } else {
        await repo.add(uid, txn);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).brightness == Brightness.dark
              ? ColorScheme.dark(primary: context.colors.primary, surface: context.colors.surface)
              : ColorScheme.light(primary: context.colors.primary),
        ),
        child: child!,
      ),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_date),
      );
      if (pickedTime != null) {
        setState(() {
          _date = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(
        _type == TransactionType.expense
            ? expenseCategoriesProvider
            : incomeCategoriesProvider);

    if (_selectedCategory == null && widget.existing != null) {
      final catList = categories.valueOrNull ?? [];
      try {
        _selectedCategory = catList.firstWhere((c) => c.id == widget.existing!.categoryId);
      } catch (_) {}
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle and Title
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: context.colors.divider, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.existing != null ? 'Edit Expense' : 'Add Expense', style: context.textStyles.heading.copyWith(fontSize: 20)),
                      if (widget.existing != null)
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded, color: context.colors.expenseRed),
                          onPressed: () {}, // Delete logic mapping
                        )
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Amount Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: context.colors.ink.withAlpha(10), blurRadius: 15, offset: const Offset(0, 8))
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: context.textStyles.displayAmount.copyWith(fontSize: 40),
                          validator: Validators.amount,
                          decoration: InputDecoration(
                            hintText: 'N0.00',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Text('Enter Amount', style: context.textStyles.caption),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _QuickAmountPill(amount: 500, onTap: () => _addQuickAmount(500)),
                            const SizedBox(width: 12),
                            _QuickAmountPill(amount: 1000, onTap: () => _addQuickAmount(1000)),
                            const SizedBox(width: 12),
                            _QuickAmountPill(amount: 2000, onTap: () => _addQuickAmount(2000)),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Category Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Category', style: context.textStyles.subheading),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: context.colors.surface,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                            builder: (_) => AddCategorySheet(type: _type == TransactionType.expense ? 'expense' : 'income'),
                          );
                        },
                        child: Text('+ Add New', style: context.textStyles.bodyMedium.copyWith(color: context.colors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  categories.when(
                    data: (cats) => SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: cats.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, i) {
                          final cat = cats[i];
                          final isSelected = _selectedCategory?.id == cat.id;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? context.colors.primary : context.colors.surfaceSubtle,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: isSelected ? context.colors.primary : Colors.transparent),
                                    boxShadow: isSelected ? [BoxShadow(color: context.colors.primary.withAlpha(50), blurRadius: 10, offset: const Offset(0, 4))] : null,
                                  ),
                                  child: Icon(cat.icon, size: 20, color: isSelected ? context.colors.onInk : cat.color),
                                ),
                                const SizedBox(height: 8),
                                Text(cat.name, style: context.textStyles.label),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 24),

                  // Note Text Field
                  Text('Note (Optional)', style: context.textStyles.label),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noteCtrl,
                    decoration: InputDecoration(
                      hintText: 'Add Note',
                      prefixIcon: Icon(Icons.edit_note_rounded, size: 18, color: context.colors.textMuted),
                      suffixText: '0/100',
                      fillColor: context.colors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.divider, width: 0.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.divider, width: 0.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.primary, width: 1)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Details (Date Box)
                  Text('Details', style: context.textStyles.label),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.colors.divider, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 18, color: context.colors.textMuted),
                          const SizedBox(width: 12),
                          Text('Date & Time', style: context.textStyles.body),
                          const Spacer(),
                          Text(DateFormat("MMM d, yyyy 'at' h:mm a").format(_date), style: context.textStyles.bodyMedium),
                          const SizedBox(width: 8),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: context.colors.textPrimary),
                        ],
                      ),
                    ),
                  ),

                  // Payment Method
                  const SizedBox(height: 24),
                  Text('Payment Method', style: context.textStyles.label),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _paymentMethods.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final method = _paymentMethods[i];
                        final isSelected = _paymentMethod == method;
                        return GestureDetector(
                          onTap: () => setState(() => _paymentMethod = method),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? context.colors.primary : context.colors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? context.colors.primary : context.colors.divider),
                            ),
                            child: Text(
                              method,
                              style: context.textStyles.caption.copyWith(
                                color: isSelected ? context.colors.onInk : context.colors.textPrimary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                  ),

                  // Receipt Box
                  const SizedBox(height: 24),
                  Text('Receipt number', style: context.textStyles.label),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _receiptCtrl,
                    style: context.textStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Add receipt number',
                      hintStyle: context.textStyles.caption,
                      fillColor: context.colors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.divider, width: 0.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.divider, width: 0.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.primary, width: 1)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary.withAlpha(120), // Setting to muted green matching screenshot specifically. Using a vibrant green will require actual alpha masking, but this is simple.
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      onPressed: _loading ? null : _save,
                      child: _loading
                          ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.onInk))
                          : Text(widget.existing != null ? 'Update Expense' : 'Save Expense', style: context.textStyles.buttonLabel),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAmountPill extends StatelessWidget {
  const _QuickAmountPill({required this.amount, required this.onTap});
  final double amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: context.colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('N${amount.toInt()}', style: context.textStyles.caption.copyWith(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
