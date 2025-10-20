import 'package:google_sign_in/google_sign_in.dart';
import 'package:daily_habits/features/habits/models/user_model.dart';
import 'package:daily_habits/core/database/habit_database_service.dart';

/// Service for handling Google Sign-In authentication
class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  final HabitDatabaseService _databaseService = HabitDatabaseService();

  /// Sign in with Google
  /// Returns a User object if successful, null otherwise
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Check if user already exists in database
      final existingUser = await _databaseService.getUserByEmail(googleUser.email);

      if (existingUser != null) {
        // User exists, return the existing user
        return existingUser;
      }

      // Create new user from Google account
      final newUser = User(
        name: googleUser.displayName ?? 'User',
        email: googleUser.email,
        password: null, // No password for Google sign-in users
        language: 'ar',
        theme: 'light',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Insert user into database
      await _databaseService.insertUser(newUser);

      // Retrieve the newly created user with ID
      final createdUser = await _databaseService.getUserByEmail(googleUser.email);

      return createdUser;
    } catch (error) {
      // Handle errors
      print('Error signing in with Google: $error');
      return null;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      print('Error signing out from Google: $error');
    }
  }

  /// Check if user is currently signed in with Google
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Get current Google user
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Silent sign-in (attempt to sign in without user interaction)
  Future<User?> signInSilently() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();

      if (googleUser == null) {
        return null;
      }

      // Check if user exists in database
      final existingUser = await _databaseService.getUserByEmail(googleUser.email);

      return existingUser;
    } catch (error) {
      print('Error during silent sign-in: $error');
      return null;
    }
  }
}
