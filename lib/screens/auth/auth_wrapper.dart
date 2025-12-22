import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    print('🔷 AuthWrapper initialized');
  }

  @override
  Widget build(BuildContext context) {
    print('🔷 AuthWrapper building...');

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('═══════════════════════════════════════');
        print('🔷 AuthWrapper StreamBuilder Update');
        print('🔷 ConnectionState: ${snapshot.connectionState}');
        print('🔷 HasData: ${snapshot.hasData}');
        print('🔷 HasError: ${snapshot.hasError}');
        if (snapshot.hasData) {
          print('🔷 User ID: ${snapshot.data?.uid}');
          print('🔷 User Email: ${snapshot.data?.email}');
          print('🔷 User Name: ${snapshot.data?.displayName}');
        }
        print('═══════════════════════════════════════');

        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ Showing loading screen');
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF5E60CE),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        // Show error if something went wrong
        if (snapshot.hasError) {
          print('❌ Auth error: ${snapshot.error}');
          if (snapshot.error.toString().contains('permission-denied')) {
            print(
              '🔓 Permission denied during transition, redirecting to Login',
            );
            return const LoginScreen();
          }
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Force rebuild
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // If user is logged in, show home screen
        if (snapshot.hasData && snapshot.data != null) {
          print('✅ User is logged in, navigating to HomeScreen');
          return const HomeScreen();
        }

        // If user is not logged in, show login screen
        print('🔓 No user logged in, showing LoginScreen');
        return const LoginScreen();
      },
    );
  }
}
