import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/download/download_bloc.dart';
import 'package:walldecor/bloc/download/download_event.dart';
import 'package:walldecor/bloc/library/library_bloc.dart';
import 'package:walldecor/bloc/library/library_event.dart';
import 'package:walldecor/bloc/library/libray_state.dart';
import 'package:walldecor/models/categorydetailes_model.dart';
import 'package:walldecor/models/all_library_model.dart';
import 'package:walldecor/repositories/download_image_repository.dart';
import 'package:walldecor/screens/navscreens/subscriptionpage.dart';

Future<bool?> showDownloadConfirmationDialog({
  required BuildContext context,
  // required String imageUrl,
}) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      bool isLoading = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF40424E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Download Wallpaper',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(12),
                //   child: Image.network(
                //     imageUrl,
                //     height: 150,
                //     width: double.infinity,
                //     fit: BoxFit.cover,
                //   ),
                // ),
                // const SizedBox(height: 15),
                const Text(
                  'Are you sure you want to download this wallpaper?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                 style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE5776),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed:
                    isLoading
                        ? null
                        : () {
                          setState(() => isLoading = true);
                          Navigator.of(context).pop(true);
                        },
                child:
                    isLoading
                        ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'Download',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> showDownloadLimitDialog({
  required BuildContext context,
  required int currentCount,
  required int maxLimit,
}) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF40424E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Download Limit Reached',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'You have reached your download limit of $maxLimit images. Upgrade to Pro for unlimited downloads.',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE5776),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to subscription page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionPage(),
                ),
              );
            },
            child: const Text(
              'Upgrade to Pro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> showAddFloorDialog({
  required BuildContext context,
  required String imageUrl,
  required Function(String) onCreate,
}) async {
  final controller = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF40424E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create New Library',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.white54, thickness: 1),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF50525C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter library name',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(105, 38),
                    backgroundColor: const Color(0xFFEE5776),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.5),
                    ),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    final libraryName = controller.text.trim();
                    if (libraryName.isNotEmpty) {
                      onCreate(libraryName);
                      Navigator.pop(context);
                      // Note: This function doesn't have access to proper Urls/User objects
                      // so it cannot create the library via API
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> AddLibraryDialog({
  required BuildContext context,
  required Urls urls,
  required User user,
  required Function(String) onCreate,
}) async {
  final controller = TextEditingController();

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: context.read<LibraryBloc>(),
        child: BlocListener<LibraryBloc, LibraryState>(
          listener: (context, state) {
            if (state is LibrarySuccess) {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'New library created successfully!',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            } else if (state is LibraryError) {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to create library: ${state.message}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          child: Dialog(
            backgroundColor: const Color(0xFF40424E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create New Library',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.white54, thickness: 1),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF50525C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter library name',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  BlocBuilder<LibraryBloc, LibraryState>(
                    builder: (context, state) {
                      final isLoading = state is LibraryLoading;
                      return Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(105, 38),
                            backgroundColor: const Color(0xFFEE5776),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                          ),
                          onPressed:
                              isLoading
                                  ? null
                                  : () {
                                    final libraryName = controller.text.trim();
                                    if (libraryName.isNotEmpty) {
                                      onCreate(libraryName);
                                      context.read<LibraryBloc>().add(
                                        CreateLibraryEvent(
                                          token: "",
                                          libraryName: libraryName,
                                          id:
                                              "lib_${DateTime.now().millisecondsSinceEpoch}",
                                          urls: urls,
                                          user: user,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please enter a library name',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  },
                          child:
                              isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'Save',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> EditlibraryDialog({
  required BuildContext context,
  required String libraryId,
  required String currentName,
  required Function(String) onCreate,
}) async {
  final controller = TextEditingController(text: currentName);

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: context.read<LibraryBloc>(),
        child: BlocListener<LibraryBloc, LibraryState>(
          listener: (context, state) {
            if (state is LibraryRenameSuccess) {
              Navigator.pop(dialogContext);
              // Refresh the library list to show updated name
              context.read<LibraryBloc>().add(GetAllLibraryEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Library renamed successfully!',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (state is LibraryError) {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to rename library: ${state.message}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          child: Dialog(
            backgroundColor: const Color(0xFF40424E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rename Library',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.white54, thickness: 1),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF50525C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter new library name',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  BlocBuilder<LibraryBloc, LibraryState>(
                    builder: (context, state) {
                      final isLoading = state is LibraryLoading;
                      return Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(105, 38),
                            backgroundColor: const Color(0xFFEE5776),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                          ),
                          onPressed:
                              isLoading
                                  ? null
                                  : () {
                                    final newLibraryName =
                                        controller.text.trim();
                                    if (newLibraryName.isNotEmpty &&
                                        newLibraryName != currentName) {
                                      onCreate(newLibraryName);
                                      context.read<LibraryBloc>().add(
                                        RenameLibraryEvent(
                                          libraryId: libraryId,
                                          libraryName: newLibraryName,
                                        ),
                                      );
                                    } else if (newLibraryName.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please enter a library name',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    } else {
                                      Navigator.pop(dialogContext);
                                    }
                                  },
                          child:
                              isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'Save',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class SaveLibrarySheet extends StatefulWidget {
  final String id;
  final Urls urls;
  final User user;

  const SaveLibrarySheet({super.key, required this.id, required this.urls, required this.user});
  @override
  State<SaveLibrarySheet> createState() => _SaveLibrarySheetState();
}

class _SaveLibrarySheetState extends State<SaveLibrarySheet> {
  @override
  void initState() {
    super.initState();
    // Fetch library data when the sheet is opened
    context.read<LibraryBloc>().add(GetAllLibraryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(' '),
              const Text(
                'Save to Library',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          // Show dynamic library list from API
          BlocConsumer<LibraryBloc, LibraryState>(
            listener: (context, state) {
              if (state is LibraryUpdateSuccess) {
                Navigator.pop(context);
                // Refresh the library list to show updated counts
                context.read<LibraryBloc>().add(GetAllLibraryEvent());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Image added to library successfully!',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (state is LibraryError) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to add image to library: ${state.message}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is LibraryLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(color: Color(0xFFEE5776)),
                  ),
                );
              }

              if (state is LibraryLoaded) {
                final libraries = state.data;
                return Column(
                  children: [
                    // Show dynamic library list
                    ...libraries.map(
                      (library) => _DynamicLibraryItem(
                        library: library,
                        urls: widget.urls,
                        user: widget.user,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Download to Gallery option
                    ListTile(
                      leading: Image.asset('assets/navbaricons/download.png', height: 24, width: 24, color: Colors.white),
                      title: const Text(
                        'Download to Gallery',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () async{
                        
                         final confirmed = await showDownloadConfirmationDialog(
                          context: context,
                        );

                        if (confirmed == true) {

                          await downloadImageToGallery(widget.urls.regular);
                          final imageId = widget.id;

                          final urlsJson = {
                            "full": widget.urls.full,
                            "regular": widget.urls.regular,
                            "small": widget.urls.small,
                          };

                          final userJson = {
                            "id": widget.user.id,
                            "username": widget.user.username,
                            "name": widget.user.name,
                            "first_name": widget.user.firstName,
                            "last_name": widget.user.lastName,
                            "profile_link": widget.user.profileLink,
                            "profile_image": widget.user.profileImage,
                          };

                          context.read<DownloadBloc>().add(
                            AddToDownloadEvent(
                              id: imageId,
                              urls: urlsJson,
                              user: userJson,
                            ),
                          );

                          debugPrint(
                            'Downloading  with ID: $imageId',
                          );
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                );
              }

              if (state is LibraryError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        'Error loading libraries: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          context.read<LibraryBloc>().add(GetAllLibraryEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEE5776),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DynamicLibraryItem extends StatelessWidget {
  final AllLibraryModel library;
  final Urls urls;
  final User user;

  const _DynamicLibraryItem({
    required this.library,
    required this.urls,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          library.savedImage.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  library.savedImage.first.url.small,
                  width: 30,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 30,
                        height: 48,
                        color: const Color(0xFF3A3D47),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Color(0xFF868EAE),
                          size: 20,
                        ),
                      ),
                ),
              )
              : Container(
                width: 30,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3D47),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF868EAE),
                  size: 20,
                ),
              ),
      title: Text(library.name, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        '${library.totalImage} images',
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      onTap: () {
        // Add image to this library
        context.read<LibraryBloc>().add(
          UpdateLibraryEvent(libraryId: library.id, urls: urls, user: user),
        );
      },
    );
  }
}
