import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:walldecor/bloc/guest/guest_bloc.dart';
import 'package:walldecor/bloc/guest/guest_state.dart';
import 'package:walldecor/screens/bottomscreens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:walldecor/screens/bottomscreens/librarypage.dart';
import 'package:walldecor/screens/bottomscreens/profilescreen.dart';
import 'package:walldecor/screens/detailedscreens/collectiondetails.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  List<Widget> bottomScreens = [
    const Homescreen(),
    const Librarypage(),
    const CollectionDetailsPage(title: 'Allover Homestyle',),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestBloc, GuestState>(
      listener: (context, state) {
        if (state is GuestError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor:  Color(0xFFEE5776),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<GuestBloc, GuestState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFF25272F),
            body: Stack(
              children: [
                bottomScreens[currentIndex],
                if (state is GuestLoading)
                  Container(
                    color: const Color(0xFF25272F).withOpacity(0.7),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEE5776)),
                      ),
                    ),
                  ),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF25272F),
                border: Border(top: BorderSide(color: Color(0xFF3A3D47), width: 0.5)),
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
                  onTap: (index) => setState(() => currentIndex = index),
                  selectedItemColor: const Color(0xFFEE5776),
                  unselectedItemColor: const Color(0xFF868EAE),
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  elevation: 0,
                  items: [
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/svg/home.svg',
                          color: currentIndex == 0
                              ? const Color(0xFFEE5776)
                              : const Color(0xFF868EAE),
                          width: 24,
                          height: 24),
                      label: "",
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/svg/library.svg',
                          color: currentIndex == 1
                              ? const Color(0xFFEE5776)
                              : const Color(0xFF868EAE),
                          width: 24,
                          height: 24),
                      label: "",
                    ),
                   BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/svg/grid.svg',
                          color: currentIndex == 2
                              ? const Color(0xFFEE5776)
                              : const Color(0xFF868EAE),
                          width: 24,
                          height: 24),
                      label: "",
                    ),
                    BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/svg/person.svg',
                          color: currentIndex == 3
                              ? const Color(0xFFEE5776)
                              : const Color(0xFF868EAE),
                          width: 24,
                          height: 24),
                      label: "",
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
