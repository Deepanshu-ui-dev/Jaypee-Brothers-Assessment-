import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/category_model.dart';
import '../../providers/category_provider.dart';
import 'package:uuid/uuid.dart';

class AddCategorySheet extends ConsumerStatefulWidget {
  const AddCategorySheet({super.key, required this.type});
  final String type; // 'expense' or 'income'

  @override
  ConsumerState<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<AddCategorySheet> {
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  IconData _selectedIcon = Icons.stars_rounded;
  Color _selectedColor = const Color(0xFF4B6ECA); // default primary
  bool _loading = false;

  final List<IconData> _availableIcons = const [
    Icons.stars_rounded,
    Icons.home_rounded,
    Icons.shopping_bag_rounded,
    Icons.fastfood_rounded,
    Icons.directions_car_rounded,
    Icons.medical_services_rounded,
    Icons.school_rounded,
    Icons.flight_takeoff_rounded,
    Icons.pets_rounded,
    Icons.sports_esports_rounded,
    Icons.work_rounded,
    Icons.fitness_center_rounded,
    Icons.local_cafe_rounded,
    Icons.subscriptions_rounded,
    Icons.child_care_rounded,
    Icons.build_rounded,
  ];

  final List<Color> _availableColors = const [
    Color(0xFF4B6ECA), // primary
    Color(0xFF8E909B), // dark gray
    Color(0xFFFFB340), // yellow
    Color(0xFF5CCDA0), // green
    Color(0xFFE56969), // red
    Color(0xFF9B51E0), // purple
    Color(0xFF2D9CDB), // light blue
    Color(0xFFF2994A), // orange
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final cat = CategoryModel(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
      bgColor: _selectedColor.withAlpha(50),
      type: widget.type,
      isDefault: false,
    );

    await ref.read(categoryNotifierProvider.notifier).addCategory(cat);
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('New ${widget.type == 'income' ? 'Income' : 'Expense'} Category', 
                          style: context.textStyles.heading.copyWith(fontSize: 20)),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: context.colors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Name
                  Text('Category Name', style: context.textStyles.label),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter a name' : null,
                    decoration: InputDecoration(
                      hintText: 'e.g. Subscriptions',
                      fillColor: context.colors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.divider, width: 0.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.divider, width: 0.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.primary, width: 1)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Color
                  Text('Color', style: context.textStyles.label),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableColors.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final color = _availableColors[i];
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                             border: isSelected ? Border.all(color: context.colors.textPrimary, width: 2) : null,
                            ),
                            child: isSelected ? Icon(Icons.check_rounded, color: context.colors.onInk, size: 20) : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Icon
                  Text('Icon', style: context.textStyles.label),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, i) {
                      final icon = _availableIcons[i];
                      final isSelected = _selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? _selectedColor.withOpacity(0.2) : context.colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected ? Border.all(color: _selectedColor, width: 1.5) : Border.all(color: context.colors.divider, width: 0.5),
                          ),
                          child: Icon(icon, color: isSelected ? _selectedColor : context.colors.textMuted),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      onPressed: _loading ? null : _save,
                      child: _loading
                          ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.onInk))
                          : Text('Save Category', style: context.textStyles.buttonLabel),
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
