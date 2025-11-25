import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:walldecor/bloc/auth/auth_bloc.dart';
import 'package:walldecor/screens/bottomscreens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:walldecor/screens/bottomscreens/premiumscreen.dart';
// import 'package:walldecor/screens/bottomscreens/librarypage.dart';
import 'package:walldecor/screens/library/librarypreview.dart';
import 'package:walldecor/screens/bottomscreens/profilescreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  late List<Widget> bottomScreens;
  final GlobalKey<ProfileScreenState> _profileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    getFcmToken();
    bottomScreens = [
      Homescreen(),
      const LibrarypageData(),
      const PremiumScreen(),
      ProfileScreen(
        key: _profileKey,
        onTabChange: (index) => setState(() => currentIndex = index),
      ),
    ];
  }

  void getFcmToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print('🔥 FCM Token: $token');
    // loginWithGoogle();
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: const Color(0xFF25272F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Center(
                  child: const Text(
                    'Exit App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                content: const Text(
                  'Are you sure you want to exit the App?',
                  style: TextStyle(color: Color(0xFF868EAE), fontSize: 14),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(100, 40),
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          'Stay',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(100, 40),
                          backgroundColor: Color(0xFFEE5776),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          SystemNavigator.pop();
                        },
                        child: const Text(
                          'Exit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'An error occurred'),
              backgroundColor: Color(0xFFEE5776),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              backgroundColor: const Color(0xFF25272F),
              body: Stack(
                children: [
                  bottomScreens[currentIndex],
                ],
              ),
              bottomNavigationBar: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF25272F),
                  border: Border(
                    top: BorderSide(color: Color(0xFF3A3D47), width: 0.5),
                  ),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: const Color(0xFF25272F),
                    currentIndex: currentIndex,
                    onTap: (index) {
                      setState(() => currentIndex = index);
                      // // Refresh profile data when profile tab is selected
                      // if (index == 3 && _profileKey.currentState != null) {
                      //   // Trigger a refresh for the profile screen
                      //   _profileKey.currentState!.refreshProfileData();
                      // }
                    },
                    selectedItemColor: const Color(0xFFEE5776),
                    unselectedItemColor: const Color(0xFF868EAE),
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    elevation: 0,
                    items: [
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          'assets/svg/home.svg',
                          color:
                              currentIndex == 0
                                  ? const Color(0xFFEE5776)
                                  : const Color(0xFF868EAE),
                          width: 24,
                          height: 24,
                        ),
                        label: "",
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          'assets/svg/library.svg',
                          color:
                              currentIndex == 1
                                  ? const Color(0xFFEE5776)
                                  : const Color(0xFF868EAE),
                          width: 24,
                          height: 24,
                        ),
                        label: "",
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          'assets/svg/grid.svg',
                          color:
                              currentIndex == 2
                                  ? const Color(0xFFEE5776)
                                  : const Color(0xFF868EAE),
                          width: 24,
                          height: 24,
                        ),
                        label: "",
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          'assets/svg/person.svg',
                          color:
                              currentIndex == 3
                                  ? const Color(0xFFEE5776)
                                  : const Color(0xFF868EAE),
                          width: 24,
                          height: 24,
                        ),
                        label: "",
                      ),
                    ],
                  ),
                ),
              ),
            ), // WillPopScope
          );
        },
      ),
    );
  }
}
