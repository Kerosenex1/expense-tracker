// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '/screens/transaction_model.dart';

// class DatabaseHelper {
//   static final DatabaseHelper instance = DatabaseHelper._init();
//   static Database? _database;

//   DatabaseHelper._init();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('transactions.db');
//     return _database!;
//   }

//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);

//     return await openDatabase(path, version: 1, onCreate: _createDB);
//   }

//   Future _createDB(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE transactions (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         type TEXT NOT NULL,
//         amount REAL NOT NULL,
//         category TEXT NOT NULL,
//         description TEXT NOT NULL,
//         date TEXT NOT NULL,
//         createdAt TEXT NOT NULL
//       )
//     ''');
//   }

//   Future<int> insertTransaction(TransactionModel transaction) async {
//     final db = await database;
//     return await db.insert('transactions', transaction.toMap());
//   }

//   Future<List<TransactionModel>> getAllTransactions() async {
//     final db = await database;
//     final result = await db.query(
//       'transactions',
//       orderBy: 'date DESC, createdAt DESC',
//     );
//     return result.map((map) => TransactionModel.fromMap(map)).toList();
//   }

//   Future<int> updateTransaction(TransactionModel transaction) async {
//     final db = await database;
//     return await db.update(
//       'transactions',
//       transaction.toMap(),
//       where: 'id = ?',
//       whereArgs: [transaction.id],
//     );
//   }

//   Future<int> deleteTransaction(int id) async {
//     final db = await database;
//     return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
//   }

//   Future close() async {
//     final db = await database;
//     db.close();
//   }
// }
