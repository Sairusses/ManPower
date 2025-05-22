import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // sign up method
  Future<String?> signup({
      required String username,
      required String email,
      required String password,
      required BuildContext context
    }) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      showToast("Fields cannot be empty");
      return null;
    }
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}").hasMatch(email)) {
      showToast("Invalid email format");
      return null;
    }
    try{
      showLoadingDialog(context);
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          "username": username,
          "email": email,
          "role": "",
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
      if(context.mounted) Navigator.pop(context);
      return user?.uid;
    }on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e.code);
      showToast(errorMessage);
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
      showToast("Email or password cannot be empty");
      return null;
    }
    try {
      showLoadingDialog(context);
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
            'users').doc(user.uid).get();
        String role = userDoc['role'];
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      showToast(_getFirebaseErrorMessage(e.code));
    }
  }

  //helper methods
  Future<void> showToast(String message, {Color backgroundColor = Colors.transparent}) async {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: backgroundColor,
      textColor: Colors.black,
      fontSize: 14,
      gravity: ToastGravity.SNACKBAR,
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
