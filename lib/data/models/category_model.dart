import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;      // icon color
  final Color bgColor;    // tint background
  final String type;      // 'expense' | 'income' | 'both'
  final bool isDefault;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.type,
    this.isDefault = false,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String,
      icon: _getIconData(data['iconCodePoint'] as int),
      color: Color(data['colorValue'] as int),
      bgColor: Color(data['bgColorValue'] as int),
      type: data['type'] as String,
      isDefault: data['isDefault'] as bool? ?? false,
    );
  }

  static IconData _getIconData(int codePoint) {
    const icons = <IconData>[
      Icons.restaurant_rounded,
      Icons.directions_car_rounded,
      Icons.shopping_bag_rounded,
      Icons.movie_rounded,
      Icons.favorite_rounded,
      Icons.school_rounded,
      Icons.bolt_rounded,
      Icons.home_rounded,
      Icons.spa_rounded,
      Icons.more_horiz_rounded,
      Icons.account_balance_wallet_rounded,
      Icons.laptop_rounded,
      Icons.trending_up_rounded,
      Icons.card_giftcard_rounded,
      Icons.refresh_rounded,
      Icons.stars_rounded,
      Icons.fastfood_rounded,
      Icons.medical_services_rounded,
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
    for (final icon in icons) {
      if (icon.codePoint == codePoint) return icon;
    }
    return Icons.more_horiz_rounded;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.value,
      'bgColorValue': bgColor.value,
      'type': type,
      'isDefault': isDefault,
    };
  }
}

// ─── Default Categories ──────────────────────────────────────────────────────

final List<CategoryModel> kDefaultExpenseCategories = [
  CategoryModel(
    id: 'food',
    name: 'Food & Dining',
    icon: Icons.restaurant_rounded,
    color: const Color(0xFF1A7A4A),
    bgColor: const Color(0xFFE6F6ED),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'transport',
    name: 'Transport',
    icon: Icons.directions_car_rounded,
    color: const Color(0xFF2A4DB3),
    bgColor: const Color(0xFFE8EDFB),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'shopping',
    name: 'Shopping',
    icon: Icons.shopping_bag_rounded,
    color: const Color(0xFFB33A3A),
    bgColor: const Color(0xFFFFF4E3),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'entertainment',
    name: 'Entertainment',
    icon: Icons.movie_rounded,
    color: const Color(0xFF6B2AB3),
    bgColor: const Color(0xFFF0E8FB),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'health',
    name: 'Health',
    icon: Icons.favorite_rounded,
    color: const Color(0xFF993C1D),
    bgColor: const Color(0xFFFFECE5),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'education',
    name: 'Education',
    icon: Icons.school_rounded,
    color: const Color(0xFF2A4DB3),
    bgColor: const Color(0xFFE8EDFB),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'utilities',
    name: 'Utilities',
    icon: Icons.bolt_rounded,
    color: const Color(0xFF996B00),
    bgColor: const Color(0xFFFFF8E1),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'rent',
    name: 'Rent',
    icon: Icons.home_rounded,
    color: const Color(0xFF555555),
    bgColor: const Color(0xFFF0F0F0),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'personal_care',
    name: 'Personal Care',
    icon: Icons.spa_rounded,
    color: const Color(0xFFB32A6B),
    bgColor: const Color(0xFFFCE8F3),
    type: 'expense',
    isDefault: true,
  ),
  CategoryModel(
    id: 'other_expense',
    name: 'Other',
    icon: Icons.more_horiz_rounded,
    color: const Color(0xFF555555),
    bgColor: const Color(0xFFF0F0F0),
    type: 'expense',
    isDefault: true,
  ),
];

final List<CategoryModel> kDefaultIncomeCategories = [
  CategoryModel(
    id: 'salary',
    name: 'Salary',
    icon: Icons.account_balance_wallet_rounded,
    color: const Color(0xFF1A7A4A),
    bgColor: const Color(0xFFE6F6ED),
    type: 'income',
    isDefault: true,
  ),
  CategoryModel(
    id: 'freelance',
    name: 'Freelance',
    icon: Icons.laptop_rounded,
    color: const Color(0xFF2A4DB3),
    bgColor: const Color(0xFFE8EDFB),
    type: 'income',
    isDefault: true,
  ),
  CategoryModel(
    id: 'investment',
    name: 'Investment',
    icon: Icons.trending_up_rounded,
    color: const Color(0xFF996B00),
    bgColor: const Color(0xFFFFF8E1),
    type: 'income',
    isDefault: true,
  ),
  CategoryModel(
    id: 'gift',
    name: 'Gift',
    icon: Icons.card_giftcard_rounded,
    color: const Color(0xFFB32A6B),
    bgColor: const Color(0xFFFCE8F3),
    type: 'income',
    isDefault: true,
  ),
  CategoryModel(
    id: 'refund',
    name: 'Refund',
    icon: Icons.refresh_rounded,
    color: const Color(0xFF993C1D),
    bgColor: const Color(0xFFFFECE5),
    type: 'income',
    isDefault: true,
  ),
  CategoryModel(
    id: 'other_income',
    name: 'Other',
    icon: Icons.more_horiz_rounded,
    color: const Color(0xFF555555),
    bgColor: const Color(0xFFF0F0F0),
    type: 'income',
    isDefault: true,
  ),
];

List<CategoryModel> get kAllDefaultCategories =>
    [...kDefaultExpenseCategories, ...kDefaultIncomeCategories];

extension CategoryModelX on CategoryModel {
  Color themedBgColor(BuildContext context) {
    if (!isDefault) return bgColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    
    switch (id) {
      case 'food': return colors.tintFood;
      case 'salary': return colors.tintFood;
      case 'transport': return colors.tintTransport;
      case 'freelance': return colors.tintTransport;
      case 'shopping': return colors.tintShopping;
      case 'entertainment': return colors.tintPurple;
      case 'health': return colors.tintHealth;
      case 'refund': return colors.tintHealth;
      case 'education': return colors.tintEducation;
      case 'utilities': return colors.tintSoftware;
      case 'investment': return colors.tintSoftware;
      case 'rent': return colors.tintGray;
      case 'personal_care': return colors.tintPink;
      case 'gift': return colors.tintPink;
      case 'other_expense': return colors.tintGray;
      case 'other_income': return colors.tintGray;
      default: return bgColor;
    }
  }
}
