import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/auth/auth_bloc.dart';
import 'package:walldecor/repositories/services/image_service.dart';
import 'package:walldecor/screens/detailedscreens/collectiondetailspage.dart';
import 'package:walldecor/screens/detailedscreens/resultpage.dart';
import 'package:walldecor/bloc/category/category_bloc.dart';
import 'package:walldecor/bloc/category/category_event.dart';
import 'package:walldecor/bloc/category/category_state.dart';
import 'package:walldecor/bloc/collection/collection_bloc.dart';
import 'package:walldecor/bloc/collection/collection_event.dart';
import 'package:walldecor/bloc/collection/collection_state.dart';
import 'package:walldecor/bloc/connectivity/connectivity_bloc.dart';
import 'package:walldecor/bloc/connectivity/connectivity_event.dart';
import 'package:walldecor/bloc/connectivity/connectivity_state.dart';
import 'package:walldecor/bloc/download/download_bloc.dart';
import 'package:walldecor/bloc/download/download_event.dart';
import 'package:walldecor/bloc/download/download_state.dart';
import 'package:walldecor/screens/widgets/diolog.dart';
import 'package:walldecor/screens/widgets/no_internet_widget.dart';
import 'package:walldecor/repositories/category_repository.dart';
import 'package:walldecor/repositories/collection_repository.dart';
import 'package:walldecor/models/category_model.dart';
import 'package:walldecor/models/categorydetailes_model.dart';
import 'package:walldecor/repositories/services/google_auth_service.dart';

class Homepage extends StatefulWidget {
  final Function(int)? onTabChange;
  const Homepage({super.key, this.onTabChange});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late CategoryBloc _categoryBloc;
  late CollectionBloc _collectionBloc;

  String? selectedCategoryId;
  String selectedCategoryTitle = 'All';
  List<CategorydetailesModel> categoryImages = [];

  @override
  void initState() {
    super.initState();
    _categoryBloc = CategoryBloc(CategoryRepository());
    _collectionBloc = CollectionBloc(CollectionRepository());
    // Fetch initial data
    _categoryBloc.add(FetchCategoryEvent());
    _collectionBloc.add(FetchCollectionEvent());
  }

  @override
  void dispose() {
    _categoryBloc.close();
    _collectionBloc.close();
    super.dispose();
  }

  Future<void> _checkUserAuthentication() async {
    try {
      // Check if user is logged in
      if (mounted) {
        context.read<AuthBloc>().add(
          SessionRequest(
            onSuccess: (user) {
              print(
                '✅ User session valid: ${user.email.isNotEmpty ? user.email : user.id}',
              );
              print('User type: ${user.userType}');
            },
            onError: (error) {
              print('❌ Session check failed in main screen: $error');
              print('🔄 Creating new guest session in main screen...');
              // If no session or session expired, create guest login
              _initializeGuestLogin();
            },
          ),
        );
      }
    } catch (e) {
      print('Error checking user authentication in main screen: $e');
      _initializeGuestLogin();
    }
  }

  Future<void> _initializeGuestLogin() async {
    try {
      final googleAuthService = GoogleAuthService();
      final deviceId = await googleAuthService.getDeviceId();

      // Get FCM token
      String pushToken = '';
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        pushToken = fcmToken ?? '';
      } catch (e) {
        print('Failed to get FCM token: $e');
      }

      if (mounted) {
        context.read<AuthBloc>().add(
          GuestLogin(
            deviceId: deviceId,
            pushToken: pushToken,
            onSuccess: (user) {
              print('✅ Guest login successful in main screen: ${user.id}');
              print('Guest name: ${user.firstName} ${user.lastName}');
            },
            onError: (error) {
              print('❌ Guest login failed in main screen: $error');
            },
          ),
        );
      }
    } catch (e) {
      print('Error initializing guest login in main screen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      body: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, connectivityState) {
          if (connectivityState is ConnectivityOffline) {
            return NoInternetWidget(
              onRetry: () {
                context.read<ConnectivityBloc>().add(CheckConnectivity());
              },
            );
          }
          if (connectivityState is ConnectivityOnline) {
            print('🌐 Internet restored - Rechecking session...');
            _checkUserAuthentication();
            
          }

          return MultiBlocListener(
            listeners: [
              BlocListener<CategoryBloc, CategoryState>(
                bloc: _categoryBloc,
                listener: (context, state) {
                  if (state is CategoryDetailsLoaded) {
                    setState(() {
                      categoryImages = state.data;
                    });
                  } else if (state is CategoryLoaded &&
                      selectedCategoryId == null) {
                    // Auto-select first category by default
                    final categories = state.data;
                    if (categories.isNotEmpty) {
                      setState(() {
                        selectedCategoryId = categories.first.id;
                        selectedCategoryTitle = categories.first.title;
                      });
                      _categoryBloc.add(
                        FetchCategoryDetailsEvent(categories.first.id),
                      );
                    }
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildFeaturedCollectionSection(),
                    const SizedBox(height: 16),
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
        },
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () {
                if (widget.onTabChange != null) {
                  widget.onTabChange!(2); // Switch to Collection tab (index 2)
                }
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
          child: BlocBuilder<CollectionBloc, CollectionState>(
            bloc: _collectionBloc,
            builder: (context, state) {
              if (state is CollectionLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFEE5776)),
                );
              } else if (state is CollectionLoaded) {
                final collections = state.data;
                final displayCount =
                    collections.length > 4 ? 4 : collections.length;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayCount,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CollectionDetailsPage(
                                  title: collections[index + 1].title,
                                  id: collections[index + 1].id,
                                ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12.0),
                        width: 106,
                        height: 146,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            collections[index + 1].coverPhoto.urls.regular,
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
                      ),
                    );
                  },
                );
              } else if (state is CollectionError) {
                return SizedBox(
                  height: 146,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          color: Color(0xFF868EAE),
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Unable to load collections',
                          style: TextStyle(
                            color: Color(0xFF868EAE),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
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
      child: BlocBuilder<CategoryBloc, CategoryState>(
        bloc: _categoryBloc,
        builder: (context, state) {
          print('CATEGORY BUILDER STATE -> $state');
          if (state is CategoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEE5776)),
            );
          } else if (state is CategoryLoaded ||
              state is CategoryDetailsLoading ||
              state is CategoryDetailsLoaded) {
            List<CategoryModel> categories = [];

            if (state is CategoryLoaded) {
              categories = state.data;
            } else if (state is CategoryDetailsLoading) {
              categories = state.categories;
            } else if (state is CategoryDetailsLoaded) {
              categories = state.categories;
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final bool isSelected = selectedCategoryId == category.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategoryId = category.id;
                      selectedCategoryTitle = category.title;
                    });

                    _categoryBloc.add(FetchCategoryDetailsEvent(category.id));
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
                            isSelected
                                ? Color(0xFFEE5776)
                                : const Color(0xFF868EAE),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(18.0),
                      color:
                          isSelected ? Color(0xFFEE5776) : Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        category.title,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF868EAE),
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (state is CategoryError) {
            return SizedBox(
              height: 36,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEE5776),
                      ),
                      onPressed: () {
                        _collectionBloc.add(FetchCollectionEvent());
                        _categoryBloc.add(FetchCategoryEvent());
                      },
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          color:Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildWallpapersGrid() {
    if (categoryImages.isEmpty &&
        selectedCategoryId != null &&
        selectedCategoryId!.isNotEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Color(0xFFEE5776)),
      );
    }

    if (categoryImages.isEmpty) {
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
      itemCount: categoryImages.length,
      itemBuilder: (context, index) {
        final image = categoryImages[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => Resultpage(urls: image.urls, user: image.user),
              ),
            );
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
                    child: Image.network(
                      image.urls.regular,
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
                      onTap: () async {
                        final confirmed = await showDownloadConfirmationDialog(
                          context: context,
                        );

                        if (confirmed == true) {

                          await downloadImageToGallery( image.urls.regular);
                          final imageId = image.id;

                          final urlsJson = {
                            "full": image.urls.full,
                            "regular": image.urls.regular,
                            "small": image.urls.small,
                          };

                          final userJson = {
                            "id": image.user.id,
                            "username": image.user.username,
                            "name": image.user.name,
                            "first_name": image.user.firstName,
                            "last_name": image.user.lastName,
                            "profile_link": image.user.profileLink,
                            "profile_image": image.user.profileImage,
                          };

                          context.read<DownloadBloc>().add(
                            AddToDownloadEvent(
                              id: imageId,
                              urls: urlsJson,
                              user: userJson,
                            ),
                          );

                          debugPrint(
                            'Downloading wallpaper $index with ID: $imageId',
                          );
                        }
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
