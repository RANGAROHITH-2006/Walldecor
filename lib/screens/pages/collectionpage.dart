import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:walldecor/screens/detailedscreens/collectiondetails.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final List<Map<String, String>> collections = [
    {'title': 'Nature', 'image': 'assets/collection/collection1.png'},
    {'title': 'Mountain', 'image': 'assets/collection/collection2.png'},
    {'title': 'Birds', 'image': 'assets/collection/collection3.png'},
    {'title': 'Abstract', 'image': 'assets/collection/collection4.png'},
    {'title': 'Sunrise', 'image': 'assets/collection/collection5.png'},
    {'title': 'Wildlife', 'image': 'assets/home/categories3.png'},
    {'title': 'Landscape', 'image': 'assets/collection/collection1.png'},
    {'title': 'Forest', 'image': 'assets/collection/collection2.png'},
    {'title': 'Ocean', 'image': 'assets/collection/collection3.png'},
    {'title': 'Desert', 'image': 'assets/collection/collection4.png'},
    {'title': 'City', 'image': 'assets/collection/collection5.png'},
    {'title': 'Space', 'image': 'assets/home/categories3.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: StaggeredGrid.count(
            crossAxisCount: 6,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(collections.length, (index) {
              return _buildStaggeredItem(index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildStaggeredItem(int index) {
    final item = collections[index];
    final positionInGroup = index % 6;
    int crossAxisCellCount;
    int mainAxisCellCount;

    switch (positionInGroup) {
      case 0:
        crossAxisCellCount = 3;
        mainAxisCellCount = 4;
        break;
      case 1:
        crossAxisCellCount = 3;
        mainAxisCellCount = 2;
        break;
      case 2:
        crossAxisCellCount = 3;
        mainAxisCellCount = 2;
        break;
      case 3:
        crossAxisCellCount = 6;
        mainAxisCellCount = 3;
        break;
      case 4:
        crossAxisCellCount = 6;
        mainAxisCellCount = 3;
        break;
      case 5:
        crossAxisCellCount = 6;
        mainAxisCellCount = 3;
        break;
      default:
        crossAxisCellCount = 2;
        mainAxisCellCount = 2;
    }

    return StaggeredGridTile.count(
      crossAxisCellCount: crossAxisCellCount,
      mainAxisCellCount: mainAxisCellCount,
      child: _buildImageCard(
        item['title']!,
        item['image']!,
        isLarge: positionInGroup == 0,
      ),
    );
  }

  Widget _buildImageCard(String title, String image, {bool isLarge = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollectionDetailsPage(title: title),
          ),
        );
        debugPrint('Tapped: $title');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                image,
                fit: BoxFit.fill,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: const Color(0xFF3A3D47),
                      child: Icon(
                        Icons.image_not_supported,
                        color: const Color(0xFF868EAE),
                        size: isLarge ? 50 : 30,
                      ),
                    ),
              ),

              Positioned(
                left: 8,
                right: 8,
                bottom: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          shadows: const [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(isLarge ? 6 : 4),
                      child: Image.asset(
                        'assets/navbaricons/playicon.png',
                        width: 42,
                        height: 19,
                      ),
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
