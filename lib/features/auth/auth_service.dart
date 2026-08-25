import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum AuthOutcome { success, canceled, failed }

class AuthService {
  AuthService._();

  static const iosClientId =
      '322608639935-4d2s3qibh1kme8scmkh6aiv7lal5ijt0.apps.googleusercontent.com';

  /// Web client ID from Firebase (Google Cloud → Credentials). Needed so
  /// Google’s ID token audience matches what Firebase Auth expects.
  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  static var _googleReady = false;

  static Future<void> initialize() async {
    if (_googleReady) return;
    try {
      await GoogleSignIn.instance.initialize(
        clientId: iosClientId,
        serverClientId: googleServerClientId.isEmpty
            ? null
            : googleServerClientId,
      );
      _googleReady = true;
    } catch (error, stack) {
      debugPrint('Google Sign-In init failed: $error\n$stack');
      _googleReady = false;
    }
  }

  static String? lastMessage;

  static Future<AuthOutcome> signInWithApple() async {
    lastMessage = null;
    try {
      final rawNonce = _nonce();
      final nonce = _sha256(rawNonce);
      final apple = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      final idToken = apple.identityToken;
      if (idToken == null) {
        lastMessage = 'Apple didn’t return a sign-in token.';
        return AuthOutcome.failed;
      }

      final credential = OAuthProvider(
        'apple.com',
      ).credential(idToken: idToken, rawNonce: rawNonce);
      final result = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final given = apple.givenName;
      final family = apple.familyName;
      final name = [
        if (given != null && given.isNotEmpty) given,
        if (family != null && family.isNotEmpty) family,
      ].join(' ');
      if (name.isNotEmpty && (result.user?.displayName ?? '').isEmpty) {
        unawaited(result.user?.updateDisplayName(name) ?? Future<void>.value());
      }

      unawaited(_rememberUser(result.user));
      return AuthOutcome.success;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return AuthOutcome.canceled;
      }
      lastMessage = e.message;
      return AuthOutcome.failed;
    } on FirebaseAuthException catch (e) {
      if (_isCanceled(e.code)) return AuthOutcome.canceled;
      lastMessage = _messageFor(e, fallback: 'Couldn’t sign in with Apple.');
      return AuthOutcome.failed;
    } catch (error, stack) {
      debugPrint('Apple sign-in failed: $error\n$stack');
      lastMessage = 'Couldn’t sign in with Apple.';
      return AuthOutcome.failed;
    }
  }

  static Future<AuthOutcome> signInWithGoogle() async {
    lastMessage = null;
    try {
      UserCredential result;
      await initialize();
      if (_googleReady) {
        try {
          final account = await GoogleSignIn.instance.authenticate(
            scopeHint: const ['email', 'profile'],
          );
          final idToken = account.authentication.idToken;
          if (idToken == null) {
            lastMessage = 'Google didn’t return a sign-in token.';
            return AuthOutcome.failed;
          }
          result = await FirebaseAuth.instance.signInWithCredential(
            GoogleAuthProvider.credential(idToken: idToken),
          );
        } on GoogleSignInException catch (e) {
          if (e.code == GoogleSignInExceptionCode.canceled) {
            return AuthOutcome.canceled;
          }
          debugPrint('Native Google sign-in failed: $e');
          result = await _googleWithFirebaseProvider();
        } catch (error) {
          debugPrint('Native Google sign-in failed: $error');
          result = await _googleWithFirebaseProvider();
        }
      } else {
        result = await _googleWithFirebaseProvider();
      }
      unawaited(_rememberUser(result.user));
      return AuthOutcome.success;
    } on FirebaseAuthException catch (e) {
      if (_isCanceled(e.code)) return AuthOutcome.canceled;
      debugPrint('Google Firebase sign-in failed: ${e.code} ${e.message}');
      lastMessage = _messageFor(e, fallback: 'Couldn’t sign in with Google.');
      return AuthOutcome.failed;
    } catch (error, stack) {
      debugPrint('Google sign-in failed: $error\n$stack');
      lastMessage = 'Couldn’t sign in with Google.';
      return AuthOutcome.failed;
    }
  }

  static Future<UserCredential> _googleWithFirebaseProvider() {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile');
    return FirebaseAuth.instance.signInWithProvider(provider);
  }

  static Future<void> signOut() async {
    lastMessage = null;
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      lastMessage = 'Couldn’t sign out.';
      debugPrint('Sign out failed: $error');
    }
  }

  static Future<AuthOutcome> deleteAccount() async {
    lastMessage = null;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return AuthOutcome.success;
    try {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
      } catch (_) {}
      try {
        await user.delete();
      } on FirebaseAuthException catch (error) {
        if (error.code != 'requires-recent-login') {
          lastMessage = error.message ?? 'Couldn’t delete the account.';
          return AuthOutcome.failed;
        }
        final ready = await _reauthenticate();
        if (!ready) return AuthOutcome.failed;
        final fresh = FirebaseAuth.instance.currentUser;
        if (fresh == null) {
          lastMessage = 'Sign in again, then delete your account.';
          return AuthOutcome.failed;
        }
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(fresh.uid)
              .delete();
        } catch (_) {}
        await fresh.delete();
      }
      try {
        await GoogleSignIn.instance.disconnect();
      } catch (_) {
        try {
          await GoogleSignIn.instance.signOut();
        } catch (_) {}
      }
      return AuthOutcome.success;
    } on FirebaseAuthException catch (error) {
      lastMessage = error.message ?? 'Couldn’t delete the account.';
      return AuthOutcome.failed;
    } catch (error, stack) {
      debugPrint('Delete account failed: $error\n$stack');
      lastMessage = 'Couldn’t delete the account.';
      return AuthOutcome.failed;
    }
  }

  static Future<bool> _reauthenticate() async {
    final user = FirebaseAuth.instance.currentUser;
    final providers = user?.providerData.map((item) => item.providerId) ?? [];
    if (providers.contains('apple.com')) {
      return await signInWithApple() == AuthOutcome.success;
    }
    if (providers.contains('google.com')) {
      return await signInWithGoogle() == AuthOutcome.success;
    }
    lastMessage = 'Sign in again, then delete your account.';
    return false;
  }

  static Future<void> _rememberUser(User? user) async {
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Auth still succeeded if the profile write is blocked by rules.
    }
  }

  static String _messageFor(
    FirebaseAuthException error, {
    required String fallback,
  }) {
    final text = '${error.code} ${error.message ?? ''}'.toLowerCase();
    if (text.contains('audience') || text.contains('bundle')) {
      return 'Firebase still thinks this app is com.example.bunly. Add an iOS app with com.bunlyapp.bunly, then drop in the new GoogleService-Info.plist.';
    }
    return error.message ?? fallback;
  }

  static bool _isCanceled(String code) {
    return code == 'canceled' ||
        code == 'web-context-canceled' ||
        code == 'ERROR_CANCELLED';
  }

  static String _nonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  static String _sha256(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }
}
