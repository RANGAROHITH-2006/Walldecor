import 'package:walldecor/screens/navscreens/notificationpage.dart';
import 'package:walldecor/screens/navscreens/searchpage.dart';
import 'package:walldecor/screens/navscreens/subscriptionpage.dart';
import 'package:walldecor/screens/pages/categoriespage.dart';
import 'package:walldecor/screens/pages/collectionpage.dart';
import 'package:walldecor/screens/pages/homepage.dart';
import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int selectedTabIndex = 0;
  final List<String> tabs = ['Home', 'Categories', 'Collection'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF25272F),
        elevation: 0,
        title: const Text(
          'Wallpapers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Searchpage()),
              );
            },
            icon: Image.asset(
              'assets/navbaricons/search.png',
              width: 24,
              height: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Notificationpage()),
              );
            },
            icon: Image.asset(
              'assets/navbaricons/notification.png',
              width: 24,
              height: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubscriptionPage()),
              );
            },
            icon: Image.asset(
              'assets/navbaricons/crown.png',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              
              color: const Color(0xFF2C2E37),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(tabs.length, (index) {
                bool isSelected = selectedTabIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTabIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFF363A47)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tabs[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF868EAE),
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return const Homepage();
      case 1:
        return const Categorypage();
      case 2:
        return const CollectionPage();
      default:
        return const Homepage();
    }
  }
}
