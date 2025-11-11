import 'package:flutter/material.dart';
import 'package:walldecor/screens/navscreens/notificationpage.dart';
import 'package:walldecor/screens/navscreens/settingspage.dart';
import 'package:walldecor/static/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      appBar: AppBar( 
        backgroundColor: const Color(0xFF25272F),
        title: const Text('Profile', style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: Image.asset('assets/navbaricons/notification.png', width: 24, height: 24),
            onPressed: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) =>  Notificationpage()));
            },
          ),
          IconButton(
            icon: Image.asset('assets/navbaricons/settings.png', width: 24, height: 24),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> Settingspage()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              children: [
                IconButton(onPressed: (){}, icon: Image.asset('assets/images/profile.png', width: 80, height: 80),),        
                Text('Name Here', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),),
              ],
            ),
            const SizedBox(height: 16),
            ProfileCustomButton(image: 'assets/navbaricons/downloadlimit.png', text: 'Download Limit : 10 Img', color: '0xFF2C2E36', screen: ''),
            SizedBox(height: 12),
            ProfileCustomButton(image: 'assets/navbaricons/images.png', text: 'Library Image', color: '0xFF2C2E36', screen: '/librarydownload'),
            SizedBox(height: 12),
            ProfileCustomButton(image: 'assets/navbaricons/downloadimage.png', text: 'Download Image : 10 Img', color: '0xFFEE5776', screen: '/librarydownload'),
          ],
        ),
      ),
    );
  }
}