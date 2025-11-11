import 'package:flutter/material.dart';
import 'package:walldecor/screens/navscreens/notificationpage.dart';
import 'package:walldecor/screens/pages/downloadpage.dart';


class Librarydownload extends StatefulWidget {
  const Librarydownload({super.key});

  @override
  State<Librarydownload> createState() => _LibrarydownloadState();
}

class _LibrarydownloadState extends State<Librarydownload> {
  int selectedTabIndex = 0;
  final List<String> tabs = ['Download Image','favorite Image'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: const Color(0xFF25272F),
        elevation: 0,
         leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
        ),
        title: const Text(
          'Images',
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
                MaterialPageRoute(builder: (context) => Notificationpage()),
              );
            },
            icon: Image.asset(
              'assets/navbaricons/notification.png',
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
        return const Downloadpage();
      case 1:
        return const Downloadpage();
      default:
        return const Downloadpage();
    }
  }
}