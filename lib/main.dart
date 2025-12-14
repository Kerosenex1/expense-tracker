import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/transaction_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // debug
  // ignore: avoid_print
  print('main: start initialize');
  await Firebase.initializeApp();
  // ignore: avoid_print
  print('main: firebase initialized');
  await Hive.initFlutter();
  await Hive.openBox('something'); // do this before runApp
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Expose streams for the app to use without automatically registering listeners here.
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  Stream<User?> get idTokenChanges => _auth.idTokenChanges();

  // Optional debug helper: call this once manually if you want logging during development.
  void enableDebugLogs() {
    _auth.authStateChanges().listen(
      (user) {
        // ignore: avoid_print
        print('authStateChanges - user: $user');
      },
      onError: (e) {
        // ignore: avoid_print
        print('authStateChanges error: $e');
      },
    );

    _auth.idTokenChanges().listen((user) {
      // ignore: avoid_print
      print('idTokenChanges - user: $user');
    });
  }
}
