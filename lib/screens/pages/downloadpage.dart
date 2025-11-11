import 'package:flutter/material.dart';

class Downloadpage extends StatefulWidget {
  const Downloadpage({super.key});

  @override
  State<Downloadpage> createState() => _DownloadpageState();
}

class _DownloadpageState extends State<Downloadpage> {
final List<String> downloadedImages = [
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
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.81,
        ),
        itemCount: downloadedImages.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(downloadedImages[index]),
                fit: BoxFit.fill,
              ),
            ),
          );
        },
      ),
    );
  }
}
