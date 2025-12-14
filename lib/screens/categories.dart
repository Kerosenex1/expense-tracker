// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import '../screens/category_model.dart';

class Categories {
  static final List<CategoryModel> expenseCategories = [
    CategoryModel(
      id: 'food',
      name: 'Food & Dining',
      icon: '🍔',
      color: 0xFFFF6B6B,
    ),
    CategoryModel(
      id: 'transport',
      name: 'Transport',
      icon: '🚗',
      color: 0xFF4ECDC4,
    ),
    CategoryModel(
      id: 'shopping',
      name: 'Shopping',
      icon: '🛍️',
      color: 0xFFFF69B4,
    ),
    CategoryModel(
      id: 'entertainment',
      name: 'Entertainment',
      icon: '🎬',
      color: 0xFF9B59B6,
    ),
    CategoryModel(
      id: 'bills',
      name: 'Bills & Utilities',
      icon: '💡',
      color: 0xFFF39C12,
    ),
    CategoryModel(
      id: 'health',
      name: 'Healthcare',
      icon: '⚕️',
      color: 0xFFE74C3C,
    ),
    CategoryModel(id: 'other', name: 'Other', icon: '📦', color: 0xFF95A5A6),
  ];

  static final List<CategoryModel> incomeCategories = [
    CategoryModel(id: 'salary', name: 'Salary', icon: '💼', color: 0xFF27AE60),
    CategoryModel(
      id: 'freelance',
      name: 'Freelance',
      icon: '💻',
      color: 0xFF16A085,
    ),
    CategoryModel(
      id: 'investment',
      name: 'Investment',
      icon: '📈',
      color: 0xFF2ECC71,
    ),
    CategoryModel(id: 'gift', name: 'Gift', icon: '🎁', color: 0xFF00CED1),
    CategoryModel(id: 'other', name: 'Other', icon: '💰', color: 0xFF32CD32),
  ];

  static CategoryModel getCategory(String type, String categoryId) {
    final categories = type == 'income' ? incomeCategories : expenseCategories;
    return categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => expenseCategories.last,
    );
  }
}
