import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('🔵 Starting signup for: $email');

      // Create user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ User created: ${result.user?.uid}');
      print('✅ User email: ${result.user?.email}');

      // Add delay to ensure user is fully created
      await Future.delayed(const Duration(milliseconds: 300));

      // Get fresh user reference
      User? user = result.user;

      if (user != null) {
        try {
          // Update display name
          await user.updateDisplayName(name);
          print('✅ Display name updated to: $name');

          // Reload user to get updated info
          await user.reload();

          // Get refreshed user
          user = _auth.currentUser;
          print('✅ User reloaded, current user: ${user?.displayName}');
        } catch (profileError) {
          print('⚠️ Profile update error (non-critical): $profileError');
          // Continue even if profile update fails
        }

        // Create user document in Firestore
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid ?? result.user!.uid)
              .set({
                'email': email,
                'displayName': name,
                'createdAt': FieldValue.serverTimestamp(),
              });
          print('✅ Firestore document created');
        } catch (firestoreError) {
          print('⚠️ Firestore error (non-critical): $firestoreError');
          // Continue even if Firestore fails
        }
      }

      print('✅ Signup complete, user should be logged in');
      return null; // Success
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error: ${e.code} - ${e.message}');
      return _handleAuthException(e);
    } catch (e) {
      print('❌ Signup error: $e');
      // Check if user was actually created despite the error
      if (_auth.currentUser != null) {
        print('✅ User was created despite error');
        return null; // User was created successfully
      }
      return 'An error occurred: ${e.toString()}';
    }
  }

  // Sign in with email and password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 Starting login for: $email');

      // Sign in
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Login successful: ${result.user?.uid}');
      print('✅ User email: ${result.user?.email}');

      // Add small delay to ensure auth state is fully updated
      await Future.delayed(const Duration(milliseconds: 100));

      print('✅ Login complete');
      return null; // Success
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error: ${e.code} - ${e.message}');
      return _handleAuthException(e);
    } catch (e) {
      print('❌ Login error: $e');
      return 'Login failed: ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Reset password
  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'An error occurred. Please try again.';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
