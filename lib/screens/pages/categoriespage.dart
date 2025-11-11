import 'package:flutter/material.dart';

class Categorypage extends StatefulWidget {
  const Categorypage({super.key});

  @override
  State<Categorypage> createState() => _CategorypageState();
}

class _CategorypageState extends State<Categorypage> {
  final List<Map<String, String>> trending = [
    {'title': 'Fashion', 'image': 'assets/home/tranding1.png'},
    {'title': 'Street', 'image': 'assets/home/tranding2.png'},
    {'title': 'Beach', 'image': 'assets/home/tranding3.png'},
    {'title': 'Rivers', 'image': 'assets/home/featured1.png'},
  ];

  final List<Map<String, String>> categories = [
    {'title': 'Nature', 'image': 'assets/home/categories1.png'},
    {'title': 'Sunset Aesthetic', 'image': 'assets/home/categories2.png'},
    {'title': 'Wildlife', 'image': 'assets/home/categories3.png'},
    {'title': 'Architectures', 'image': 'assets/home/featured2.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF25272F),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trending',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: trending.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = trending[index];
                    return buildTrendingPill(item['title']!, item['image']!);
                  },
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'All Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Column(
                children:
                    categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildCategoryCard(cat['title']!, cat['image']!),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTrendingPill(String title, String imagePath) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF2E3138),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3D47)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    width: 40,
                    height: 40,
                    color: const Color(0xFF3A3D47),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Color(0xFF868EAE),
                    ),
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        debugPrint('Category tapped: $title');
      },
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF2E3138),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.fill,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        color: const Color(0xFF3A3D47),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Color(0xFF868EAE),
                        ),
                      ),
                ),
              ),

              Positioned(
                left: 16,
                bottom: 14,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Positioned(
                right: 12,
                bottom: 8,
                child: Image.asset(
                  'assets/navbaricons/playicon.png',
                  width: 42,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
