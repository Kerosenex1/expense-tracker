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
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(name);

      // Create / update user doc in Firestore
      await _createOrUpdateUserDoc(result.user!, name: name);

      // Ensure user document exists
      await FirebaseFirestore.instance
          .collection('users')
          .doc(result.user!.uid)
          .set({
            'email': email,
            'displayName': name,
            'createdAt': FieldValue.serverTimestamp(),
          });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'An error occurred. Please try again.';
    }
  }

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Ensure user doc exists/updated after sign in
      await _createOrUpdateUserDoc(cred.user!);
      return cred;
    } on FirebaseAuthException catch (e) {
      // rethrow with message so caller can show it
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // ignore leftover Hive-related errors (some old code may still run)
      final msg = e.toString();
      if (msg.contains('HiveError') ||
          msg.contains('already open') ||
          msg.contains('box')) {
        // attempt a direct firebase signOut as fallback
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {
          // swallow secondary errors to avoid blocking logout flow
        }
        return;
      }
      rethrow;
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

  // Ensure Firestore user doc exists
  Future<void> _createOrUpdateUserDoc(User user, {String? name}) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await docRef.get();
    final data = {
      'email': user.email,
      'displayName': name ?? user.displayName,
      'lastSeen': FieldValue.serverTimestamp(),
    };
    if (snapshot.exists) {
      await docRef.update(data);
    } else {
      await docRef.set({...data, 'createdAt': FieldValue.serverTimestamp()});
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
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
