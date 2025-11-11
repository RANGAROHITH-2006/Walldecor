import 'package:flutter/material.dart';

class LoginDividerLine extends StatelessWidget {
  const LoginDividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFEE5776),
                  Color(0xFFEE5776),
                  Colors.transparent,
                ],
              ),
            ),
          )
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Login With',
            style: TextStyle(color: Colors.white,fontSize: 16),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xFFEE5776),
                  Color(0xFFE7E7E7),
                ],
              ),
            ),
          )
        ),
      ],
    ) ;
  }
}