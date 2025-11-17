// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/library/library_bloc.dart';
import 'package:walldecor/bloc/library/library_event.dart';
import 'package:walldecor/bloc/library/libray_state.dart';
import 'package:walldecor/models/library_details_model.dart';
import 'package:walldecor/models/categorydetailes_model.dart';
import 'package:walldecor/screens/detailedscreens/resultpage.dart';
import 'package:walldecor/screens/static/noresult.dart';

class LibraryDetailsPage extends StatefulWidget {
  final String name;
  final String id;

  const LibraryDetailsPage({super.key, required this.name, required this.id});

  @override
  State<LibraryDetailsPage> createState() => _LibraryDetailsPageState();
}

class _LibraryDetailsPageState extends State<LibraryDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<LibraryBloc>().add(GetAllLibraryDetailsEvent(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            // Refresh library data before popping
            context.read<LibraryBloc>().add(GetAllLibraryEvent());
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 16,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF25272F),
        titleSpacing: 0,
        title: Text(widget.name, style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              
            },
            icon: Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          print('🔥 LibraryDetailsPage: Current state - ${state.runtimeType}');

          if (state is LibraryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEE5776)),
            );
          } else if (state is LibraryDetailsLoaded) {
            
            final List<LibraryDetailsModel> details = state.data;
           
            if (details.isEmpty) {
              print('🔥 LibraryDetailsPage: No details found');
              return  Noresult();
            }
            final libraryDetail = details.first;
            final savedImages = libraryDetail.savedImage;
            if (savedImages.isEmpty) {
             
              return Noresult();
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.81,
                ),
                itemCount: savedImages.length,
                itemBuilder: (context, index) {
                  final item = savedImages[index];
                  return GestureDetector(
                    onTap: () {
                      // Create proper Urls and User objects from saved image data
                      final urls = Urls(
                        full: item.url.full,
                        regular: item.url.regular,
                        small: item.url.small,
                      );

                      final user = User(
                        id: item.imageOwner.id,
                        username: item.imageOwner.username,
                        name: item.imageOwner.name,
                        firstName: item.imageOwner.firstName,
                        lastName: item.imageOwner.lastName,
                        profileLink: item.imageOwner.profileLink,
                        profileImage: item.imageOwner.profileImage,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => Resultpage(urls: urls, user: user),
                        ),
                      );
                      debugPrint('Library image $index tapped');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                item.url.small,
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
          } else if (state is LibraryError) {
            print('🔥 LibraryDetailsPage: Error state - ${state.message}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      print('🔥 LibraryDetailsPage: Retrying...');
                      context.read<LibraryBloc>().add(
                        GetAllLibraryDetailsEvent(widget.id),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is LibraryDetailsLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              print(
                '🔥 LibraryDetailsPage: Triggering GetAllLibraryDetailsEvent',
              );
              context.read<LibraryBloc>().add(
                GetAllLibraryDetailsEvent(widget.id),
              );
            });
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEE5776)),
            );
          } else {
            print(
              '🔥 LibraryDetailsPage: Unknown state - ${state.runtimeType}',
            );
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Loading library details...',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(color: Color(0xFFEE5776)),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
