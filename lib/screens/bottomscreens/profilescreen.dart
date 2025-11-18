import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/auth/auth_bloc.dart';
import 'package:walldecor/screens/navscreens/notificationpage.dart';
import 'package:walldecor/screens/navscreens/settingspage.dart';
import 'package:walldecor/screens/widgets/custom_button.dart';

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
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String userName = 'Guest User';
                
                if (state.status == AuthStatus.success && state.user != null) {
                  userName = '${state.user!.firstName} ${state.user!.lastName}'.trim();
                  if (userName.isEmpty) {
                    userName = state.user!.email.split('@')[0]; // Use email prefix if name is empty
                  }
                  
                } else {
                  userName = 'Guest User';
              
                }
                
                return Column(
                  children: [
                    IconButton(
                      onPressed: () {}, 
                      icon: Image.asset('assets/images/profile.png', width: 80, height: 80),
                    ),        
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            ProfileCustomButton(image: 'assets/navbaricons/downloadlimit.png', text: 'Download Limit : 10 Img', color: '0xFF2C2E36', screen: ''),
            SizedBox(height: 12),
            ProfileCustomButton(image: 'assets/navbaricons/images.png', text: 'Library Image', color: '0xFF2C2E36', screen: '/downloadscreen'),
            SizedBox(height: 12),
            ProfileCustomButton(image: 'assets/navbaricons/downloadimage.png', text: 'Download Image : 10 Img', color: '0xFFEE5776', screen: '/downloadscreen'),
          ],
        ),
      ),
    );
  }
}