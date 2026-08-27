import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<UserCredential> createAccount({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final sanitizedName = fullName.trim().isEmpty ? 'User' : fullName.trim();

    final credential = await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Account creation failed.');
    }

    try {
      await user.updateDisplayName(sanitizedName);
      await user.reload();
    } catch (e) {
      debugPrint('Profile update error: $e');
    }

    try {
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://growi-1.firebaseapp.com',
        handleCodeInApp: true,
        iOSBundleId: 'com.example.growiProject',
        androidPackageName: 'com.example.growiProject',
        androidInstallApp: true,
        androidMinimumVersion: '1',
      );
      await user.sendEmailVerification(actionCodeSettings);
    } catch (e) {
      debugPrint('Verification email error: $e');
    }

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'fullName': sanitizedName,
      'displayName': sanitizedName,
      'email': normalizedEmail,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'emailVerified': false,
    }, SetOptions(merge: true));

    return credential;
  }

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  static Future<void> sendVerificationEmail(User user) async {
    try {
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://growi-1.firebaseapp.com',
        handleCodeInApp: true,
        iOSBundleId: 'com.example.growiProject',
        androidPackageName: 'com.example.growiProject',
        androidInstallApp: true,
        androidMinimumVersion: '1',
      );
      await user.sendEmailVerification(actionCodeSettings);
    } catch (e) {
      debugPrint('Verification email resend error: $e');
    }
  }

  static Future<void> ensureUserProfile(User user, {String? fallbackEmail}) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return;
      }

      final fullName = (user.displayName ?? 'User').trim().isEmpty
          ? 'User'
          : user.displayName!.trim();

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': fullName,
        'fullName': fullName,
        'email': user.email ?? fallbackEmail ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': user.emailVerified,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Profile Create Error: $e');
    }
  }

  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('You need to sign in before changing your password.');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  static String getFriendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'requires-recent-login':
        return 'Please sign in again before changing your password.';
      default:
        return e.message ?? 'Something went wrong.';
    }
  }
}
