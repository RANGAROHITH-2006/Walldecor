import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/trending/trending_bloc.dart';
import 'package:walldecor/bloc/trending/trending_state.dart';
import 'package:walldecor/bloc/trending/trending_event.dart';
import 'package:walldecor/bloc/connectivity/connectivity_bloc.dart';
import 'package:walldecor/bloc/connectivity/connectivity_event.dart';
import 'package:walldecor/bloc/connectivity/connectivity_state.dart';
import 'package:walldecor/bloc/search/search_bloc.dart';
import 'package:walldecor/bloc/search/search_state.dart';
import 'package:walldecor/bloc/search/search_event.dart';
import 'package:walldecor/screens/widgets/no_internet_widget.dart';
import 'package:walldecor/screens/widgets/noresult.dart';


class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  Timer? _debounceTimer;

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
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    // Cancel previous timer
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      return;
    }

    // Start new timer for debouncing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        context.read<SearchBloc>().add(CreateSearchEvent(text: query));
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    _debounceTimer?.cancel();
    setState(() {
      _isSearching = false;
    });
  }

  // Helper method to safely extract image URL from search result
  String _getImageUrl(Map<String, dynamic> item) {
    try {
      if (item.containsKey('urls') && item['urls'] is Map) {
        final urls = item['urls'] as Map<String, dynamic>;
        return urls['small'] ?? urls['regular'] ?? urls['thumb'] ?? '';
      } else if (item.containsKey('thumbnail')) {
        return item['thumbnail'] ?? '';
      } else if (item.containsKey('url')) {
        return item['url'] ?? '';
      }
      return '';
    } catch (e) {
      print("Error extracting image URL: $e");
      return '';
    }
  }

  // Helper method to safely extract image description from search result
  String _getImageDescription(Map<String, dynamic> item) {
    try {
      return item['description'] ??
          item['alt_description'] ??
          item['title'] ??
          item['text'] ??
          '';
    } catch (e) {
      print("Error extracting image description: $e");
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, connectivityState) {
          if (connectivityState is ConnectivityOffline) {
            return NoInternetWidget(
              onRetry: () {
                context.read<ConnectivityBloc>().add(CheckConnectivity());
              },
            );
          }
          
          return SafeArea(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                  // Dismiss keyboard when scrolling starts
                  FocusScope.of(context).unfocus();
                }
                return false;
              },
              child: Column(
                children: [
                  Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: (value) {
                              _onSearchChanged(value);
                              setState(() {}); // Rebuild to update suffix icon
                            },
                            style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search here',
                            hintStyle: const TextStyle(color: Color(0xFF646770)),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF646770),
                              size: 22,
                            ),
                            suffixIcon:
                                _searchController.text.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white70,
                                      ),
                                      onPressed: _clearSearch,
                                    )
                                    : const Icon(Icons.close, color: Colors.white70),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        _isSearching ? _buildSearchResults() : _buildOriginalContent(),
                      ],
                    ),
                                ),
                  ),
                ],
              ),
            ),
          );
        },
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is SearchError) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 50),
               Noresult(),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      context.read<SearchBloc>().add(CreateSearchEvent(text: _searchController.text));
                    }
                  },
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Color(0xFFEE5776),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is SearchSuccess) {
          List<dynamic> results = [];
          try {
            if (state.data.containsKey('results')) {
              results = state.data['results'] as List<dynamic>? ?? [];
            } else if (state.data is List) {
              results = state.data as List<dynamic>;
            } else {
              // Handle other possible structures
              results = [];
            }
          } catch (e) {
            print("Error parsing search results: $e");
            results = [];
          }

          if (results.isEmpty) {
            return _buildNoResultsScreen();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Results (${results.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                itemCount: results.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.81,
                ),
                itemBuilder: (context, index) {
                  final item = results[index] as Map<String, dynamic>? ?? {};
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _getImageUrl(item),
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white,
                                ),
                              ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        if (_getImageDescription(item).isNotEmpty)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Text(
                              _getImageDescription(item),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        }

        // Initial state - show message to start searching
        return Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Icon(Icons.search, color: Colors.grey[600], size: 64),
              const SizedBox(height: 16),
              Text(
                'Start typing to search collections',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoResultsScreen() {
    return
      Image.asset(
        'assets/images/noresult.png',
        width: double.infinity,
        height: 200,
      );
  }

  Widget _buildOriginalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------- Carousel ----------------
        CarouselSlider(
          items:
              carouselImages.map((image) {
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
          children:
              carouselImages.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 4.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentIndex == entry.key
                            ? Colors.white
                            : Colors.grey[600],
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
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    const Icon(
                      Icons.wifi_off,
                      color: Color(0xFF868EAE),
                      size: 32,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to load trending',
                      style: TextStyle(
                        color: Color(0xFF868EAE),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        context.read<TrendingBloc>().add(FetchSearchTrendingEvent());
                      },
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          color: Color(0xFFEE5776),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
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
                          errorBuilder:
                              (_, __, ___) => const Icon(
                                Icons.image_not_supported,
                                color: Colors.white,
                              ),
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
    );
  }
}
