import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String type; // 'income' | 'expense'
  final String category;
  final String description;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'type': type,
    'category': category,
    'description': description,
    'date': date.toUtc().toIso8601String(),
  };

  factory TransactionModel.fromMap(String id, Map<String, dynamic> m) {
    // Handle both Timestamp and String date formats
    DateTime parsedDate;

    parsedDate = (m['date'] as Timestamp).toDate();
    return TransactionModel(
      id: id,
      amount: (m['amount'] as num).toDouble(),
      type: m['type'] as String,
      category: m['category'] as String? ?? '',
      description: m['description'] as String? ?? '',
      date: parsedDate.toLocal(),
    );
  }

  factory TransactionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }
    return TransactionModel.fromMap(doc.id, data as Map<String, dynamic>);
  }
}
