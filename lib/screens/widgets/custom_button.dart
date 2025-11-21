import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:walldecor/bloc/auth/auth_bloc.dart';
import 'package:walldecor/repositories/services/google_auth_service.dart';
import 'package:walldecor/repositories/services/apple_auth_service.dart';
import 'dart:io';

class CustomButton extends StatefulWidget {
  final String color;
  final String image;
  final String text;
  final String screen;
  const CustomButton({
    super.key,
    required this.image,
    required this.text,
    required this.color,
    required this.screen,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isLoading = false;

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final googleAuthService = GoogleAuthService();
      final userData = await googleAuthService.signInWithGoogle();

      if (userData != null) {
        if (context.mounted) {
          context.read<AuthBloc>().add(
            LoginWithGoogle(
              firstName: userData['firstName']!,
              lastName: userData['lastName']!,
              googleIdToken: userData['idToken']!,
              deviceId: userData['deviceId']!,
              email: userData['email']!,
              firebaseUserId: userData['firebaseUserId']!,
              pushToken: userData['pushToken']!,
              profileImageUrl: userData['profileImageUrl']!,
              onSuccess: (user) {
                print('Login successful: ${user.id}');
              },
              onError: (error) {
                print('Login failed: $error');
              },
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleAppleSignIn(BuildContext context) async {
    try {
      setState(() => isLoading = true);

      // Check if Apple Sign In is available
      if (!Platform.isIOS && !Platform.isMacOS) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Apple Sign-In is only available on iOS and macOS'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final appleAuthService = AppleAuthService();

      // Check availability
      final isAvailable = await appleAuthService.isAppleSignInAvailable();
      if (!isAvailable) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Apple Sign-In is not available on this device'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final userData = await appleAuthService.signInWithApple();

      if (userData != null) {
        if (context.mounted) {
          context.read<AuthBloc>().add(
            LoginWithApple(
              firstName: userData['firstName']!,
              lastName: userData['lastName']!,
              appleIdToken: userData['idToken']!,
              deviceId: userData['deviceId']!,
              email: userData['email']!,
              firebaseUserId: userData['firebaseUserId']!,
              pushToken: userData['pushToken']!,
              appleUserId: userData['appleUserId'],
              onSuccess: (user) {
                print('Apple login successful: ${user.id}');
              },
              onError: (error) {
                print('Apple login failed: $error');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Apple Sign-In failed: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple Sign-In failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> googleSignIn() async {
    try {
      setState(() => isLoading = true);

      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
        final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
        print("Firebase ID Token: $token");
        if (mounted) {
          context.go('/mainscreen');
        }
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (widget.text == 'Login With Google') {
          await googleSignIn();
          await _handleGoogleSignIn(context);
          context.pop();
        } else if (widget.text == 'Login With Apple') {
          await _handleAppleSignIn(context);
        } else {
          context.push(widget.screen);
        }
      },
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(int.parse(widget.color)),
          borderRadius: BorderRadius.circular(25),
        ),
        child:
            isLoading
                ? Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFEE5776),
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(widget.image),
                    const SizedBox(width: 8),
                    Text(
                      widget.text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
      ),
    );
  }
}

class ProfileCustomButton extends StatelessWidget {
  final String color;
  final String image;
  final String text;
  final String screen;
  final VoidCallback? onTap;
  const ProfileCustomButton({
    super.key,
    required this.image,
    required this.text,
    required this.color,
    required this.screen,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else if (screen.isNotEmpty) {
          context.push(screen);
        }
      },
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(int.parse(color)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(image),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCustomButton1 extends StatelessWidget {
  final String color;
  final String image;
  final String text;
  final VoidCallback? onTap;
  const ProfileCustomButton1({
    super.key,
    required this.image,
    required this.text,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(int.parse(color)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(image),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
