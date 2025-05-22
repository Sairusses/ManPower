import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manpower/mobile/auth/auth_service.dart';
import 'package:manpower/mobile/auth/log_in.dart';
import 'package:manpower/mobile/client/home_client.dart';
import '../../components/custom_text_form_field.dart';
import '../../freelancer/home_freelancer.dart';

class CreateAccount extends StatefulWidget{
  final String role;
  const CreateAccount({super.key, required this.role});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

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
            SizedBox(
              height: 45,
              width: double.infinity,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                  : ElevatedButton(
                onPressed: () async {
                  if (usernameController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      passwordController.text.isEmpty ||
                      confirmPasswordController.text.isEmpty) {
                    Fluttertoast.showToast(msg: "Fields cannot be empty");
                    return;
                  }
                  if (passwordController.text != confirmPasswordController.text) {
                    Fluttertoast.showToast(msg: "Passwords do not match");
                    return;
                  }

                  setState(() => isLoading = true);

                  String? userId = await AuthService().signup(
                    username: usernameController.text.trim(),
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                    role: widget.role,
                  );

                  setState(() => isLoading = false);

                  if (userId != null && context.mounted) {
                    if (widget.role == 'client') {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => HomeClient()),
                            (route) => false,
                      );
                    } else if (widget.role == 'freelancer') {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => HomeFreelancer()),
                            (route) => false,
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Sign Up'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Login())
                );
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
          child: Text('Grow your career with us',
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
