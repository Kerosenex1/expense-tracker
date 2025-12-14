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
    'date': Timestamp.fromDate(date),
  };

  factory TransactionModel.fromMap(String id, Map<String, dynamic> m) {
    return TransactionModel(
      id: id,
      amount: (m['amount'] as num).toDouble(),
      type: m['type'] as String,
      category: m['category'] as String? ?? '',
      description: m['description'] as String? ?? '',
      date: (m['date'] as Timestamp).toDate(),
    );
  }

  factory TransactionModel.fromDoc(DocumentSnapshot doc) =>
      TransactionModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
}
