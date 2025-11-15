import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:walldecor/screens/static/diolog.dart';

class Librarypage extends StatelessWidget {
  const Librarypage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> collections = [
      {
        'title': 'Allover Homestyle',
        'count': '80 Images',
        'mainImage': 'assets/collection/collection1.png',
        'thumbnails': [
          'assets/collection/collection2.png',
          'assets/collection/collection3.png',
          'assets/collection/collection4.png',
        ],
      },
      {
        'title': 'Dreams Creative',
        'count': '55 Images',
        'mainImage': 'assets/collection/collection1.png',
        'thumbnails': [
          'assets/collection/collection2.png',
          'assets/collection/collection3.png',
          'assets/collection/collection4.png',
        ],
      },
      {
        'title': 'Ruff Shed',
        'count': '20 Images',
        'mainImage': 'assets/collection/collection1.png',
        'thumbnails': [
          'assets/collection/collection2.png',
          'assets/collection/collection3.png',
          'assets/collection/collection4.png',
        ],
      },
      {
        'title': 'Mermaid Graphics',
        'count': '65 Images',
        'mainImage': 'assets/collection/collection1.png',
        'thumbnails': [
          'assets/collection/collection2.png',
          'assets/collection/collection3.png',
          'assets/collection/collection4.png',
        ],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF25272F),
        elevation: 0,
        leading: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: 20,
        ),
        titleSpacing: 0,
        title: const Text(
          'Image Library',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: collections.length,
          itemBuilder: (context, index) {
            final collection = collections[index];
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF252634),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP SECTION (Main + Thumbnails together)
                  Expanded(
                    flex: 4,
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.asset(
                              collection['mainImage'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 83,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: const Color(0xFF3A3D47),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Color(0xFF868EAE),
                                      size: 40,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Thumbnails
                          Row(
                            children: [
                              ...List.generate(3, (thumbnailIndex) {
                                return Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      right: thumbnailIndex < 2 ? 4 : 0,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Image.asset(
                                          collection['thumbnails'][thumbnailIndex],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    color: const Color(
                                                      0xFF3A3D47,
                                                    ),
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                      color: Color(0xFF868EAE),
                                                      size: 16,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // BOTTOM SECTION (Text + SVG icon)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 6.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Texts
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              collection['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              collection['count'],
                              style: const TextStyle(
                                color: Color(0xFF868EAE),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            EditlibraryDialog(
                              context: context,
                              onCreate: (libraryName) {},
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/svg/Pen.svg',
                            width: 22,
                            height: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
