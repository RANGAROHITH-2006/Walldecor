import 'package:flutter/material.dart';

class Noresult extends StatelessWidget {
  const Noresult({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF25272F),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/noresult.png',
              width: double.infinity,
              height: 310,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}