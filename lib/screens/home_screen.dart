import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/transaction_model.dart';
import '../screens/categories.dart';
import '../services/auth_service.dart';
import 'add_transaction_screen.dart';
import 'analytics_screen.dart';
import 'transactions_screen.dart';
import '1profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Get transactions stream from Firestore
  Stream<List<TransactionModel>> get transactionsStream {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TransactionModel.fromDoc(doc))
              .toList();
        });
  }

  double getTotalIncome(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getBalance(List<TransactionModel> transactions) {
    return getTotalIncome(transactions) - getTotalExpense(transactions);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionModel>>(
      stream: transactionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final transactions = snapshot.data ?? [];

        final List<Widget> screens = [
          _buildDashboard(transactions),
          const TransactionsScreen(),
          const AnalyticsScreen(),
          const ProfileScreen(),
        ];

        return Scaffold(
          body: screens[_selectedIndex],
          floatingActionButton: _selectedIndex < 3
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTransactionScreen(),
                      ),
                    );
                  },
                  backgroundColor: const Color(0xFF5E60CE),
                  child: const Icon(Icons.add),
                )
              : null,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF5E60CE),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Transactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboard(List<TransactionModel> transactions) {
    final totalIncome = getTotalIncome(transactions);
    final totalExpense = getTotalExpense(transactions);
    final balance = getBalance(transactions);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5E60CE), Color(0xFF6930C3)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(balance, totalIncome, totalExpense),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: _buildRecentTransactions(transactions),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double balance, double totalIncome, double totalExpense) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expense Tracker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome, ${user?.displayName ?? 'User'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              IconButton( //logout button
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await AuthService().signOut();
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Balance',
                  balance,
                  Icons.account_balance_wallet,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Income',
                  totalIncome,
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'Expenses',
            totalExpense,
            Icons.trending_down,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color == Colors.white
                  ? Colors.white
                  : (color is MaterialColor ? color.shade300 : color),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(List<TransactionModel> transactions) {
    final recentTransactions = transactions.take(5).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (recentTransactions.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('📊', style: TextStyle(fontSize: 64)),
                    SizedBox(height: 16),
                    Text(
                      'No transactions yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap + to add your first transaction',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: recentTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = recentTransactions[index];
                  final category = Categories.getCategory(
                    transaction.type,
                    transaction.category,
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(category.color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            category.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      title: Text(
                        transaction.description.isEmpty
                            ? category.name
                            : transaction.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Text(
                        "${transaction.type == 'income' ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: transaction.type == 'income'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
