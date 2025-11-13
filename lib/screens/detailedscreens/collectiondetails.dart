import 'package:flutter/material.dart';
import 'package:walldecor/screens/detailedscreens/showresultpage.dart';
import 'package:walldecor/screens/navscreens/notificationpage.dart';
import 'package:walldecor/screens/navscreens/searchpage.dart';

class CollectionDetailsPage extends StatefulWidget {
  final String title;
  const CollectionDetailsPage({super.key, required this.title});

  @override
  State<CollectionDetailsPage> createState() => _CollectionDetailsPageState();
}

class _CollectionDetailsPageState extends State<CollectionDetailsPage> {
  List<String> images = [
    'assets/collection/collection1.png',
    'assets/collection/collection2.png',
    'assets/collection/collection3.png',
    'assets/collection/collection4.png',
    'assets/collection/collection5.png',
    'assets/home/discover2.png',
    'assets/collection/collection1.png',
    'assets/collection/collection2.png',
    'assets/collection/collection3.png',
    'assets/collection/collection4.png',
    'assets/collection/collection5.png',
    'assets/home/discover2.png',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF25272F),
        elevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
       actions: [
          IconButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) =>  Searchpage()));
            }, 
            icon: Image.asset('assets/navbaricons/search.png', width: 24, height: 24),
          ),
          IconButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) =>  Notificationpage()));
            }, 
            icon: Image.asset('assets/navbaricons/notification.png', width: 24, height: 24),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.81,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Showresultpage(imagePath:images[index])));
              debugPrint('image $index tapped');
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF3A3D47),
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Color(0xFF868EAE),
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          debugPrint('Downloading wallpaper $index');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Downloading wallpaper...'),
                              backgroundColor: const Color(0xFF3A3D47),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0x33000000),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.asset(
                            'assets/navbaricons/download.png',
                            width: 16,
                            height: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
            ),
      ),
    
      
    );
  }
}
