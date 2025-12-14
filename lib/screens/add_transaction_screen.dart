import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/transaction_model.dart';
import '../screens/categories.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionScreen({Key? key, this.transaction}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late String _category;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _type = widget.transaction?.type ?? 'expense';
    _category = widget.transaction?.category ?? 'food';
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );
    _selectedDate = widget.transaction?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? 'Add Transaction' : 'Edit Transaction',
        ),
        backgroundColor: const Color(0xFF5E60CE),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 24),
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaction Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTypeButton('Expense', 'expense', Colors.red)),
            const SizedBox(width: 16),
            Expanded(child: _buildTypeButton('Income', 'income', Colors.green)),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton(String label, String value, Color color) {
    final isSelected = _type == value;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _type = value;
          _category = value == 'income' ? 'salary' : 'food';
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Amount',
        prefixText: '\$ ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        if (double.tryParse(value) == null || double.parse(value) <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    final categories = _type == 'income'
        ? Categories.incomeCategories
        : Categories.expenseCategories;

    return DropdownButtonFormField<String>(
      value: _category,
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: categories.map((cat) {
        return DropdownMenuItem(
          value: cat.id,
          child: Row(
            children: [
              Text(cat.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text(cat.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _category = value!);
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description (Optional)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      maxLines: 2,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate.day.toString() +
                  '/' +
                  _selectedDate.month.toString() +
                  '/' +
                  _selectedDate.year.toString(),
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveTransaction,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5E60CE),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        widget.transaction == null ? 'Add Transaction' : 'Update Transaction',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be signed in to add transactions.'),
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid amount')));
      return;
    }

    final tx = TransactionModel(
      id: '', // Firestore will assign the id
      amount: amount,
      type: _type, // 'income' or 'expense' from your form
      category: _category,
      description: _descriptionController.text.trim(),
      date: DateTime.now(),
    );

    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions');
    await col.add(tx.toMap());

    if (!mounted) return;
    Navigator.pop(context); // return to previous screen
  }
}
