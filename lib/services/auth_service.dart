import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await UserService().ensureUserDocument(userCredential.user!);
      }
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Google: $e');
      }
      rethrow; // Allow UI to handle specific errors
    }
  }

  // Email/Password Sign In
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await UserService().ensureUserDocument(credential.user!);
      }
      return credential;
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in: $e');
      }
      rethrow; // Rethrow to handle in UI
    }
  }

  // Sign Up
  Future<UserCredential?> signUp(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        // After potential update, ensure user document creates/updates with name
        await UserService().ensureUserDocument(credential.user!);
      }
      
      return credential;
    } catch (e) {
      if (kDebugMode) {
        print('Error signing up: $e');
      }
      rethrow;
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (kDebugMode) {
        print('Error sending reset email: $e');
      }
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }
}
