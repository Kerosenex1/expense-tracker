import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/auth_service.dart';
import '../../screens/home_screen.dart';
import 'login_screen.dart';
import '../transaction_model.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in - open their Hive box
          return FutureBuilder(
            future: _openUserBox(snapshot.data!.uid),
            builder: (context, boxSnapshot) {
              if (boxSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return const HomeScreen();
            },
          );
        }

        // User is not logged in
        return const LoginScreen();
      },
    );
  }

  Future<void> _openUserBox(String userId) async {
    final boxName = 'transactions_' + userId;
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<TransactionModel>(boxName);
    }
  }
}
