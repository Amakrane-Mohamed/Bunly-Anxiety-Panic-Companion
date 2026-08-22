import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum AuthOutcome { success, canceled, failed }

class AuthService {
  AuthService._();

  static var _googleReady = false;

  static Future<void> initialize() async {
    if (_googleReady) return;
    try {
      await GoogleSignIn.instance.initialize();
      _googleReady = true;
    } catch (_) {
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

      final credential = OAuthProvider('apple.com').credential(
        idToken: idToken,
        rawNonce: rawNonce,
        accessToken: apple.authorizationCode,
      );
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
        await result.user?.updateDisplayName(name);
      }

      await _rememberUser(result.user);
      return AuthOutcome.success;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return AuthOutcome.canceled;
      }
      lastMessage = e.message;
      return AuthOutcome.failed;
    } on FirebaseAuthException catch (e) {
      if (_isCanceled(e.code)) return AuthOutcome.canceled;
      lastMessage = e.message ?? 'Couldn’t sign in with Apple.';
      return AuthOutcome.failed;
    } catch (_) {
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
          result = await _googleWithFirebaseProvider();
        }
      } else {
        result = await _googleWithFirebaseProvider();
      }
      await _rememberUser(result.user);
      return AuthOutcome.success;
    } on FirebaseAuthException catch (e) {
      if (_isCanceled(e.code)) return AuthOutcome.canceled;
      lastMessage = e.message ?? 'Couldn’t sign in with Google.';
      return AuthOutcome.failed;
    } catch (_) {
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
