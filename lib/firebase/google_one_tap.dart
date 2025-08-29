import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'], // Add recommended scopes
  );

  Future<UserCredential?> signInWithOneTap() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential;

    } on FirebaseAuthException catch (e) {
      print(
        'Firebase Auth Error during Google sign-in: ${e.code} - ${e.message}',
      );
      return null;
    } catch (e) {
      print('Unexpected error during Google One Tap sign-in: $e');
      return null;
    }
  }

  Future<bool> isSignedIn() async {
    try {
      final currentUser = _auth.currentUser;
      final isGoogleSignedIn = await _googleSignIn.isSignedIn();
      return currentUser != null && isGoogleSignedIn;
    } catch (e) {
      print('Error checking sign-in status: $e');
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error during sign-out: $e');
      rethrow; // Re-throw to let caller handle the error
    }
  }

  // Optional: Add silent sign-in for auto-login
  Future<UserCredential?> signInSilently() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .signInSilently();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Silent sign-in failed: $e');
      return null;
    }
  }

  // Optional: Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
