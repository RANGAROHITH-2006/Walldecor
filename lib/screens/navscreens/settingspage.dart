import 'package:flutter/material.dart';
import 'package:walldecor/static/modeicon.dart';

class Settingspage extends StatefulWidget {
  const Settingspage({super.key});

  @override
  State<Settingspage> createState() => _SettingspageState();
}

class _SettingspageState extends State<Settingspage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      'Privacy Policy',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),

                    onTap: () {
                      // Navigate to About page
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.white),
                    title: const Text(
                      'Privacy Policy',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),

                    onTap: () {
                      // Navigate to About page
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
    );
  }
}
