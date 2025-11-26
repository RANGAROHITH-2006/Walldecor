import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:walldecor/bloc/auth/auth_bloc.dart';
import 'package:walldecor/repositories/services/google_auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
      _checkExistingSession();
    });
  }

  Future<void> _checkExistingSession() async {
    try {
      // First check if there's an existing session
      if (mounted) {
        context.read<AuthBloc>().add(
          SessionRequest(
            onSuccess: (user) {
              print('✅ Existing session found for user: ${user.email.isNotEmpty ? user.email : user.id}');
              print('User type: ${user.userType}');
              print('Is Pro User: ${user.isProUser}');
              print('Has Active Subscription: ${user.hasActiveSubscription}');
              
              if (mounted) {
                // Check if user has active subscription
                if (user.hasActiveSubscription) {
                  print('🌟 User has active subscription - navigating to main screen');
                  context.go('/mainscreen');
                } else {
                  print('💰 User does not have active subscription - navigating to subscription page');
                  context.go('/subscriptionpage');
                }
              }
            },
            onError: (error) {
              print('❌ Session check failed: $error');
              print('🔄 Creating new guest session...');
              // If no session or session expired, create guest login
              _initializeGuestLogin();
            },
          ),
        );
      }
    } catch (e) {
      print('Error checking existing session: $e');
      _initializeGuestLogin();
    }
  }

  Future<void> _initializeGuestLogin() async {
    try {
      final googleAuthService = GoogleAuthService();
      final deviceId = await googleAuthService.getDeviceId();
      
      // Get FCM token
      String pushToken = '';
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        pushToken = fcmToken ?? '';
      } catch (e) {
        print('Failed to get FCM token: $e');
      }
      
      if (mounted) {
        context.read<AuthBloc>().add(
          GuestLogin(
            deviceId: deviceId,
            pushToken: pushToken,
            onSuccess: (user) {
              print('✅ Guest login successful: ${user.id}');
              print('Guest name: ${user.firstName} ${user.lastName}');
              print('Guest Is Pro User: ${user.isProUser}');
              print('Guest Has Active Subscription: ${user.hasActiveSubscription}');
              
              if (mounted) {
                // Check if guest user has active subscription
                if (user.hasActiveSubscription) {
                  print('🌟 Guest user has active subscription - navigating to main screen');
                  context.go('/mainscreen');
                } else {
                  print('💰 Guest user does not have active subscription - navigating to subscription page');
                  context.go('/subscriptionpage');
                }
              }
            },
            onError: (error) {
              print('❌ Guest login failed: $error');
              print('⚠️ Continuing to subscription screen anyway...');
              if (mounted) {
                context.go('/subscriptionpage'); // Go to subscription page on error
              }
            },
          ),
        );
      }
    } catch (e) {
      print('Error initializing guest login: $e');
      if (mounted) {
        context.go('/subscriptionpage');
      }
    }
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
