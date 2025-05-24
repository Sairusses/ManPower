import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:manpower/onboarding_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // sign up method
  Future<String?> signup({
      required String username,
      required String email,
      required String password,
      required String role,
      required BuildContext context
    }) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      showToast("Fields cannot be empty", context);
      return null;
    }
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}").hasMatch(email)) {
      showToast("Invalid email format", context);
      return null;
    }
    try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          "username": username,
          "email": email,
          "role": role,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
      return user?.uid;
    }on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e.code);
      showToast(errorMessage, context);
      return null;
    }
  }

  //log in method
  Future<String?> login ({
    required String email,
    required String password,
    required BuildContext context
  }) async{
    if (email.isEmpty || password.isEmpty) {
      showToast("Email or password cannot be empty", context);
      return null;
    }
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      return user?.uid;
    } on FirebaseAuthException catch (e) {
      showToast(_getFirebaseErrorMessage(e.code), context);
      return null;
    }
  }

  //log out method
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    if(context.mounted){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => OnboardingScreen()), (route) => false);
    }
  }

  Future<String?> getRoleByID(String uid) async {
    DocumentSnapshot snapshot = await _firestore.collection('users').doc(uid).get();
    if(snapshot.exists){
      return snapshot['role'];
    }else {
      return null;
    }
  }

  //helper methods
  void showToast(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
    );
  }
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
    );
  }
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'user-not-found':
        return 'Invalid email.';
      case 'invalid-credential':
        return 'wrong email or password.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'Unexpected error: $errorCode';
    }
  }

}
