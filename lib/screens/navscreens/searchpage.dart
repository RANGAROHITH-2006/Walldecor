import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/trending/trending_bloc.dart';
import 'package:walldecor/bloc/trending/trending_state.dart';
import 'package:walldecor/bloc/trending/trending_event.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<TrendingBloc>().add(FetchSearchTrendingEvent());
  }

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
              // ---------------- Search Bar ----------------
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search here',
                    hintStyle: TextStyle(color: Color(0xFF646770)),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF646770), size: 22),
                    suffixIcon: Icon(Icons.close, color: Colors.white70),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ---------------- Carousel ----------------
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

              // ---------------- Carousel Dots ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: carouselImages.asMap().entries.map((entry) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key ? Colors.white : Colors.grey[600],
                    ),
                  );
                }).toList(),
              ),

              // ---------------- Trending Title ----------------
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Trending Now",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ---------------- Trending BlocBuilder ----------------
              BlocBuilder<TrendingBloc, TrendingState>(
                builder: (context, state) {
                  if (state is TrendingLoading) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state is TrendingError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (state is SearchTrendingLoaded) {
                    return GridView.builder(
                      itemCount: state.data.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final item = state.data[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                item.thumbnail,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image_not_supported, color: Colors.white),
                              ),
                              Center(
                                child: Text(
                                  item.text,
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
                    );
                  }

                  return const SizedBox();
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
