import 'package:flutter/material.dart';
import 'package:walldecor/screens/library/librarydownload.dart';
import 'package:walldecor/screens/detailedscreens/showresultpage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final List<String> featuredImages = [
    'assets/home/featured1.png',
    'assets/home/featured2.png',
    'assets/home/featured3.png',
  ];

  final List<String> categories = ['Recent', 'Nature', 'Flower', 'Mountain'];
  int selectedCategoryIndex = 0;

  final List<String> wallpapers = [
    'assets/home/discover1.png',
    'assets/home/discover2.png',
    'assets/home/discover3.png',
    'assets/home/discover4.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildFeaturedCollectionSection(),
              const SizedBox(height: 24),
              _buildDiscoverMoreSection(),
              const SizedBox(height: 16),
              _buildCategoryFilterSection(),
              const SizedBox(height: 16),
              _buildWallpapersGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFeaturedCollectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Featured Collection',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () {
                debugPrint('See more tapped');
              },
              child: const Text(
                'See more >',
                style: TextStyle(
                  color: Color(0xFF868EAE),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 146,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 12.0),
                width: 106,
                height: 146,
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),  
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    featuredImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF3A3D47),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Color(0xFF868EAE),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoverMoreSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discover More',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Discover more Wall covering',
          style: TextStyle(
            color: Color(0xFF868EAE),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilterSection() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final bool isSelected = selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategoryIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      isSelected ? Color(0xFFEE5776) : const Color(0xFF868EAE),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(18.0),
                color: isSelected ? Color(0xFFEE5776) : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF868EAE),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWallpapersGrid() {
    if (wallpapers.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text(
          'No wallpapers found for this category',
          style: TextStyle(color: Color(0xFF868EAE), fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: wallpapers.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Showresultpage(imagePath: wallpapers[index],)));
            debugPrint('Wallpaper $index tapped');
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      wallpapers[index],
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Librarydownload(),
                            ),
                          );
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
    );
  }
}
