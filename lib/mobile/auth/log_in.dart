import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manpower/mobile/auth/sign_up/role_selection.dart';
import 'package:manpower/mobile/client/home_client.dart';
import '../components/custom_text_form_field.dart';
import '../freelancer/home_freelancer.dart';
import 'auth_service.dart';

class Login extends StatefulWidget{
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    emailController.text = 'client1@client1.com';
    passwordController.text = 'client1@client1.com';
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 50,),
            Center(
                child: Icon(
                  Icons.logo_dev,
                  size: 100,
                )
            ),
            Center(
              child: Text('Welcome to ManPower',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 24, fontFamily: 'Inter', color: Colors.black
                ),
              ),
            ),
            Center(
                child: Text('Grow your career with us',
                    style: TextStyle(
                        fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.normal, color:  Colors.black
                    )
                )
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
            ForgotPasswordButton(),
            SizedBox(
              height: 45,
              width: double.infinity,
              child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.blue))
              : ElevatedButton(
                onPressed: () async{
                  setState(() => isLoading = true);
                  String? uid = await AuthService().login(email: emailController.text, password: passwordController.text);
                  if(uid != null){
                    String? role = await AuthService().getRoleByID(uid);
                    if(role == null){
                      setState(() => isLoading = false);
                    }
                    if(role == 'client') {
                      if(context.mounted){
                        setState(() => isLoading = false);
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => HomeClient()),
                              (route) => false,
                        );
                      }
                    }else if(role == 'freelancer'){
                      setState(() => isLoading = false);
                      if(context.mounted){
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => HomeFreelancer()),
                              (route) => false,
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    )
                ),
                child: Text('Log in'),
              ),
            ),
            ContinueWithDivider(),
            SocialButtons(),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => RoleSelection())
                );
              },
              child: const Text.rich(
                TextSpan(
                  text: "Don't have an account? ", style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Sign Up",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              constraints: BoxConstraints(
                  minHeight: 0,
                  maxHeight: 150
              ),
            )
          ],

        ),
      ),
    );
  }
}

class ForgotPasswordButton extends StatelessWidget{
  const ForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: TextButton(onPressed: (){
            // TODO: Forgot Password
          },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Inter',
                    color: Colors.grey[900]
                ),
              )
          ),
        )
      ],
    );
  }

}


class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {

            },

            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 5),
            ),
            child: Icon(
              Icons.logo_dev,
              color: Colors.blue,
            )
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () {

            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 5),
            ),
            child: Icon(
              Icons.logo_dev,
              color: Colors.blue,
            )
          ),
        ),
      ],
    );
  }
}

class ContinueWithDivider extends StatelessWidget {
  const ContinueWithDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[500], // Line color
            thickness: .5,       // Line thickness
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10), // Space around text
          child: Text(
            "Or continue with",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey[500], // Line color
            thickness: .5,       // Line thickness
          ),
        ),
      ],
    );
  }
}