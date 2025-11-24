import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/auth/auth_bloc.dart';
import 'package:walldecor/bloc/collection/collection_bloc.dart';
import 'package:walldecor/bloc/collection/collection_event.dart';
import 'package:walldecor/bloc/collection/collection_state.dart';
import 'package:walldecor/bloc/connectivity/connectivity_bloc.dart';
import 'package:walldecor/bloc/connectivity/connectivity_event.dart';
import 'package:walldecor/bloc/connectivity/connectivity_state.dart';
import 'package:walldecor/bloc/download/download_bloc.dart';
import 'package:walldecor/bloc/download/download_event.dart';
import 'package:walldecor/bloc/download/download_state.dart';
import 'package:walldecor/models/collectiondetailes_model.dart';
import 'package:walldecor/models/categorydetailes_model.dart' as CategoryModel;
import 'package:walldecor/repositories/download_image_repository.dart';
import 'package:walldecor/screens/detailedscreens/resultpage.dart';
import 'package:walldecor/screens/navscreens/searchpage.dart';
import 'package:walldecor/screens/widgets/diolog.dart';
import 'package:walldecor/screens/widgets/no_internet_widget.dart';
import 'package:walldecor/utils/download_restrictions.dart';

// Converter functions to convert collection models to category models
CategoryModel.Urls convertUrls(Urls urls) {
  return CategoryModel.Urls(
    full: urls.full,
    regular: urls.regular,
    small: urls.small,
  );
}

CategoryModel.User convertUser(User user) {
  return CategoryModel.User(
    id: user.id,
    username: user.username,
    name: user.name,
    firstName: user.firstName,
    lastName: user.lastName,
    profileLink: user.profileLink,
    profileImage: user.profileImage,
  );
}

class CollectionDetailsPage extends StatefulWidget {
  final String title;
  final String id;

  const CollectionDetailsPage({
    super.key,
    required this.title,
    required this.id,
  });

  @override
  State<CollectionDetailsPage> createState() => _CollectionDetailsPageState();
}

class _CollectionDetailsPageState extends State<CollectionDetailsPage> {
  @override
  void initState() {
    super.initState();
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
        ],
      ),
      body: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, connectivityState) {
          if (connectivityState is ConnectivityOffline) {
            return NoInternetWidget(
              onRetry: () {
                context.read<ConnectivityBloc>().add(CheckConnectivity());
              },
            );
          }

          return BlocListener<DownloadBloc, DownloadState>(
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
            child: BlocBuilder<CollectionBloc, CollectionState>(
              builder: (context, state) {
                if (state is CollectionLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFEE5776)),
                  );
                } else if (state is CollectionDetailsLoaded) {
                  final List<CollectiondetailesModel> details = state.data;
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
                      itemCount: details.length,
                      itemBuilder: (context, index) {
                        final item = details[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => Resultpage(
                                      id: item.id,
                                      urls: convertUrls(item.urls),
                                      user: convertUser(item.user),
                                    ),
                              ),
                            );
                            debugPrint('collection image $index tapped');
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
                                      onTap: () async {
                                        // Get current user from AuthBloc
                                        final authState = context.read<AuthBloc>().state;
                                        final currentUser = authState.user;

                                        // Check download restrictions
                                        if (DownloadRestrictions.isCompletelyBlocked(user: currentUser)) {
                                          await showDownloadBlockedDialog(
                                            context: context,
                                            message: DownloadRestrictions.getBlockedMessage(user: currentUser),
                                          );
                                          return;
                                        }

                                        if (!DownloadRestrictions.canDownload(user: currentUser)) {
                                          await showDownloadLimitDialog(
                                            context: context,
                                            currentCount: currentUser?.downloadedImage.length ?? 0,
                                            maxLimit: DownloadRestrictions.maxDownloadLimit,
                                          );
                                          return;
                                        }

                                        final confirmed =
                                            await showDownloadConfirmationDialog(
                                              context: context,
                                            );

                                        if (confirmed == true) {
                                          debugPrint(
                                            'Downloading wallpaper $index',
                                          );
                                          await downloadImageToGallery(
                                            item.urls.regular,
                                          );
                                          // Add to downloads using DownloadBloc
                                          // Use only the actual image ID without timestamp for consistency
                                          final imageId = item.id;

                                          // Convert collection model to compatible format
                                          final urlsJson = {
                                            "full": item.urls.full,
                                            "regular": item.urls.regular,
                                            "small": item.urls.small,
                                          };

                                          final userJson = {
                                            "id": item.user.id,
                                            "username": item.user.username,
                                            "name": item.user.name,
                                            "first_name": item.user.firstName,
                                            "last_name": item.user.lastName,
                                            "profile_link":
                                                item.user.profileLink,
                                            "profile_image":
                                                item.user.profileImage,
                                          };

                                          context.read<DownloadBloc>().add(
                                            AddToDownloadEvent(
                                              id: imageId,
                                              urls: urlsJson,
                                              user: userJson,
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0x33000000),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                } else if (state is CollectionError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading collection',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CollectionBloc>().add(
                              FetchCollectionDetailsEvent(widget.id),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEE5776),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
