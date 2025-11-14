import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/category/category_bloc.dart';
import 'package:walldecor/bloc/category/category_event.dart';
import 'package:walldecor/bloc/category/category_state.dart';
import 'package:walldecor/bloc/collection/collection_bloc.dart';
import 'package:walldecor/bloc/collection/collection_event.dart';
import 'package:walldecor/models/categorydetailes_model.dart';
import 'package:walldecor/screens/detailedscreens/resultpage.dart';
import 'package:walldecor/screens/navscreens/notificationpage.dart';
import 'package:walldecor/screens/navscreens/searchpage.dart';

class CategoryDetailsPage extends StatefulWidget {
  final String title;
  final String id;

  const CategoryDetailsPage({
    super.key,
    required this.title,
    required this.id,
  });

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(
      FetchCategoryDetailsEvent(widget.id),
    );
    context.read<CollectionBloc>().add(FetchCollectionDetailsEvent(widget.id));
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF25272F),
        titleSpacing: 0,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Searchpage()),
              );
            },
            icon: Image.asset(
              'assets/navbaricons/search.png',
              width: 24,
              height: 24,
            ),
          ),
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
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (state is CategoryDetailsLoaded) {
            final List<CategorydetailesModel> details = state.data;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.81,
                ),
                itemCount: details.length,
                itemBuilder: (context, index) {
                  final item = details[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  Resultpage(
                                    urls: item.urls,
                                    user: item.user,
                                  ),
                        ),
                      );
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
                              child: Image.network(
                                item.urls.small,
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
            );
          } else if (state is CategoryError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
