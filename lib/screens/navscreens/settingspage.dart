import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walldecor/screens/bottomscreens/premiumscreen.dart';
import 'package:walldecor/screens/widgets/modeicon.dart';
import 'package:walldecor/bloc/auth/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:walldecor/screens/widgets/feedback_dialog.dart';

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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF2D3037),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
            const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Are you sure you want to logout?',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton( 
                    onPressed: () {
                      Navigator.of(context).pop(); 
                      _performLogout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEE5776),
                       padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  },
);

  }

  ///share app function
  void shareApp() {
    const String packageName = "com.zooq.ai.photo.art.image.generator"; // change this
    final String playStoreLink =
        "https://play.google.com/store/apps/details?id=$packageName";

    Share.share("Check out this amazing app! Download now:\n$playStoreLink");
  }


///privacy policy function  
void openPrivacyPolicy() async {
  final url = Uri.parse("https://google.com");

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }else{
    throw('Could not launch privacy policy URL');
  }
}

  /// Show delete account confirmation dialog
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3037),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Confirm Account Deletion',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Type ‘ Delete’ to fully delete your account',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),SizedBox(height: 10,),
                const Text(
                  'This will include all your data, personal information & created posts. This action cannot be reversed.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton( 
                    onPressed: () {
                      Navigator.of(context).pop(); 
                      _performDeleteAccount();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEE5776),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Perform delete account operation
  Future<void> _performDeleteAccount() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      );

      // Trigger delete account with API call
      context.read<AuthBloc>().add(
        DeleteUser(
          onSuccess: (message) {
            Navigator.of(context).pop(); // Remove loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            print('Account deletion successful: $message');
            context.go('/splashscreen');
          },
          onError: (error) {
            Navigator.of(context).pop(); // Remove loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Delete account error: $error'),
                backgroundColor: Color(0xFFEE5776),
                duration: const Duration(seconds: 3),
              ),
            );
          },
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete account error: $e'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Perform logout operation
  Future<void> _performLogout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
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
        if (state.status == AuthStatus.initial &&
            state.user == null &&
            state.token == null) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          context.go('/splashscreen');
        } else if (state.status == AuthStatus.failure) {
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
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFF25272F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF25272F),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 18,
            ),
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
                        shareApp();
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.edit_document,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Feedback & Suggestion',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      onTap: () {
                        FeedbackDialog.show(context);
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
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ),
                      );
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
                        openPrivacyPolicy();
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
                        _showDeleteAccountDialog();
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
