import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  int _currentIndex = 0;

  final List<String> carouselImages = [
     "assets/trending/trending1.png",
     "assets/trending/trending6.png",
     "assets/trending/trending4.png",
     "assets/trending/trending3.png",
  ];

  final List<Map<String, String>> trendingList = [
    {
      "title": "River Flow",
      "image": "assets/trending/trending1.png"
    },
    {
      "title": "Abstract",
      "image": "assets/trending/trending2.png"
    },
    {
      "title": "Desert",
      "image": "assets/trending/trending3.png"
    },
    {
      "title": "Animal",
      "image": "assets/trending/trending4.png"
    },
    {
      "title": "Fish",
      "image": "assets/trending/trending5.png"
    },
    {
      "title": "Sunrise",
      "image": "assets/trending/trending6.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color(0xFF25272F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(       
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search here',
                    hintStyle: TextStyle(color: Color(0xFF646770)),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF646770), size: 22),
                    suffixIcon: const Icon(Icons.close, color: Colors.white70),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CarouselSlider(
                items: carouselImages.map((image) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 170,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: carouselImages.asMap().entries.map((entry) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key
                          ? Colors.white
                          : Colors.grey[600],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),
              Center(
                child: const Text(
                  "Trending Now",
                  style: TextStyle(color:Colors.white, fontSize: 16, fontWeight: FontWeight.bold,),
                ),
              ),
              const SizedBox(height: 10),

              GridView.builder(
                itemCount: trendingList.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final item = trendingList[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(item['image']!, fit: BoxFit.cover),
                        Center(
                          child: Text(
                            item['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
