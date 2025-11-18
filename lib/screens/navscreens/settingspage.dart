import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/screens/static/modeicon.dart';
import 'package:walldecor/bloc/auth/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Settingspage extends StatefulWidget {
  const Settingspage({super.key});

  @override
  State<Settingspage> createState() => _SettingspageState();
}

class _SettingspageState extends State<Settingspage> {
  
  /// Show logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D3037),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _performLogout();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Perform logout operation
  Future<void> _performLogout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        },
      );

      // Get FCM token for logout
      String fcmToken = '';
      try {
        final token = await FirebaseMessaging.instance.getToken();
        fcmToken = token ?? '';
      } catch (e) {
        print('Failed to get FCM token for logout: $e');
      }
      
      // Trigger logout with API call
      context.read<AuthBloc>().add(
        LogOutRequest(
          fcmToken: fcmToken,
          onSuccess: () {
            print('Logout successful');
            context.go('/splashscreen');
          },
        ),
      );
      
    } catch (e) {
      
      Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout error: $e'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
       if (state.status == AuthStatus.initial && state.user == null && state.token == null) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      context.go('/splashscreen');
    } 
    else if (state.status == AuthStatus.failure) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message ?? 'An error occurred'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  },
      child: Scaffold(
        backgroundColor: const Color(0xFF25272F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF25272F),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          ),
          titleSpacing: 0,
          title: const Text('Settings', style: TextStyle(color: Colors.white)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/settingsimages.png',
                    width: 116,
                    height: 130.0,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,

                    filterQuality: FilterQuality.medium,
                  ),
                  SizedBox(width: 10),
                  Image.asset(
                    'assets/images/Vector 1.png',
                    fit: BoxFit.cover,
                    width: 191,
                    height: 130,
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.brightness_7_outlined,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Mode',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      trailing: ToggleExample(),
                      onTap: () {
                        // Navigate to Notification settings
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.share_outlined,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Share App',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      onTap: () {
                        // Navigate to Privacy settings
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.edit_document,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Feedback & Suggetion',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      onTap: () {
                        // Navigate to About page
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.widgets_rounded,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'More App',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      onTap: () {
                        // Navigate to About page
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Privacy Policy',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      onTap: () {
                        // Navigate to About page
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.phone_outlined,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Phone',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      onTap: () {
                        // Navigate to About page
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white),
                      title: const Text(
                        'Log out',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      onTap: () {
                        _showLogoutDialog();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.white),
                      title: const Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      onTap: () {
                        // Navigate to About page
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
