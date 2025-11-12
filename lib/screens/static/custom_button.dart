import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      onTap: () {
        if (widget.text == 'Login With Google') {
          googleSignIn();
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
        child: isLoading ?
          Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>( Color(0xFFEE5776),),
                strokeWidth: 3,
                
              ),
            ),
          ) :
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(widget.image),
            const SizedBox(width: 8),
            Text(widget.text, style: const TextStyle(color: Colors.white)),
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
  const ProfileCustomButton({
    super.key,
    required this.image,
    required this.text,
    required this.color,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(screen);
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
