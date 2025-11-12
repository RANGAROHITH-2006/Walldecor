import 'package:walldecor/static/custom_button.dart';
import 'package:walldecor/static/login_divider_line.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF25272F),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 340,
              width: double.infinity,
              child: Image.asset('assets/images/login.png', fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            Text(
              'Daily inspiration to keep your screens captivating',
              style: TextStyle(color: Colors.white, fontSize: 26),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            LoginDividerLine(),
            const SizedBox(height: 20),
            CustomButton(
              image: 'assets/images/google.png',
              text: 'Login With Google',
              color: '0xFF31333C',
              screen: '/mainscreen',
            ),
            const SizedBox(height: 12),
            CustomButton(
              image: 'assets/images/apple.png',
              text: 'Login With Apple',
              color: '0xFFEE5776',
              screen: '/mainscreen',
            ),
          ],
        ),
      ),
    );
  }
}
