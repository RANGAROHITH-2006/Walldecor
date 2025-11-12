import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:walldecor/bloc/guest/guest_bloc.dart';
import 'package:walldecor/bloc/guest/guest_event.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      context.read<GuestBloc>().add(const CheckGuestEvent());
      context.go('/mainscreen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF25272F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 100, height: 100),
                SizedBox(width: 10),
                Text(
                  'Walldecor',
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Free Photos - HD Stock Images',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
