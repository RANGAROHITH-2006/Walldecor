// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:walldecor/bloc/library/library_bloc.dart';
import 'package:walldecor/bloc/library/library_event.dart';
import 'package:walldecor/bloc/library/libray_state.dart';
import 'package:walldecor/bloc/download/download_bloc.dart';
import 'package:walldecor/bloc/download/download_event.dart';
import 'package:walldecor/bloc/download/download_state.dart';
import 'package:walldecor/models/library_details_model.dart';
import 'package:walldecor/models/categorydetailes_model.dart';
import 'package:walldecor/screens/detailedscreens/resultpage.dart';
import 'package:walldecor/screens/widgets/noresult.dart';

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

  Future<bool> _onWillPop() async {
    // Refresh library data before popping, regardless of how we navigate back
    context.read<LibraryBloc>().add(GetAllLibraryEvent());
    return true; // Allow the pop
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF25272F),
          title: Center(
            child: const Text(
              'Delete Library',
              style: TextStyle(color: Colors.white),
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${widget.name}"? This action cannot be undone.',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    minimumSize: Size(100, 40),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEE5776),
                    minimumSize: Size(100, 40),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.read<LibraryBloc>().add(
                      DeleteLibraryEvent(
                        libraryId: widget.id,
                        libraryName: widget.name,
                      ),
                    );
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF25272F),
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              context.pop();
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 16,
            ),
          ),
          automaticallyImplyLeading: true,
          backgroundColor: const Color(0xFF25272F),
          titleSpacing: 0,
          title: Text(widget.name, style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              onPressed: () {
                _showDeleteConfirmationDialog(context);
              },
              icon: SvgPicture.asset('assets/svg/bin.svg'),
            ),
          ],
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<LibraryBloc, LibraryState>(
              listener: (context, state) {
                if (state is LibraryDeleteSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Library deleted successfully'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  // Navigate back - _onWillPop will handle the refresh
                  Navigator.pop(context);
                } else if (state is LibraryDeleteError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to delete library: ${state.message}',
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
            BlocListener<DownloadBloc, DownloadState>(
              listener: (context, state) {
                if (state is DownloadAddSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else if (state is DownloadAddError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Download failed: ${state.message}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<LibraryBloc, LibraryState>(
            builder: (context, state) {
              print(
                '🔥 LibraryDetailsPage: Current state - ${state.runtimeType}',
              );

              if (state is LibraryLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFEE5776)),
                );
              } else if (state is LibraryDetailsLoaded) {
                final List<LibraryDetailsModel> details = state.data;

                if (details.isEmpty) {
                  print('🔥 LibraryDetailsPage: No details found');
                  return Noresult();
                }
                final libraryDetail = details.first;
                final savedImages = libraryDetail.savedImage;
                if (savedImages.isEmpty) {
                  return Noresult();
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  (context) =>
                                      Resultpage(urls: urls, user: user),
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
                                      debugPrint(
                                        'Downloading wallpaper $index',
                                      );

                                      // Add to downloads using DownloadBloc
                                      context.read<DownloadBloc>().add(
                                        AddToDownloadEvent(
                                          id: item.id,
                                          urls: item.url.toJson(),
                                          user: item.imageOwner.toJson(),
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
        ),
      ), // WillPopScope
    );
  }
}
