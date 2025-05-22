import 'package:flutter/material.dart';
import '../../components/custom_text_form_field.dart';

class CreateAccount extends StatelessWidget{
  CreateAccount({super.key});
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(height: 75,),
            SignUpHeader(),
            CustomTextFormField(
              controller: usernameController,
              labelText: "Full Name",
              hint: "Enter your full name",
              prefixIcon: Icon(Icons.person, color: Colors.black,),
            ),
            CustomTextFormField(
              controller: emailController,
              labelText: "Email",
              hint: "Enter your email",
              prefixIcon: Icon(Icons.email, color: Colors.black,),
            ),
            CustomTextFormField(
              controller: passwordController,
              labelText: "Password",
              hint: "Enter your password",
              prefixIcon: Icon(Icons.lock, color: Colors.black,),
              isPassword: true,
            ),
            CustomTextFormField(
              controller: confirmPasswordController,
              labelText: "Confirm Password",
              hint: "Re-enter your password",
              prefixIcon: Icon(Icons.lock, color: Colors.black,),
              isPassword: true,
            ),
            SignUpButton(usernameController: usernameController, emailController: emailController, passwordController: passwordController, confirmPasswordController: confirmPasswordController,),
            TextButton(
              onPressed: () {
                // TODO: Navigate to login screen
              },
              child: const Text.rich(
                TextSpan(
                  text: "Already have an account? ", style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Log In",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 75,),
          ],
        ),
      ),
    );
  }

}

class SignUpHeader extends StatelessWidget{
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            height: 100,
            width: 100,
            child: Icon(
              Icons.logo_dev,
              size: 100,
            ),
          ),
        ),
        Center(
          child: Text('Start managing projects with AI assistance',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.normal, color:  Colors.black
            ),
          ),
        ),
      ],
    );
  }
}

class SignUpButton extends StatelessWidget{
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  const SignUpButton({super.key, required this.usernameController, required this.emailController, required this.passwordController, required this.confirmPasswordController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async{
          // TODO: Create Account
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
            )
        ),
        child: Text('Sign Up'),
      ),
    );
  }
}