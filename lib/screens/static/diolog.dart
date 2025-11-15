import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:walldecor/bloc/library/library_bloc.dart';
import 'package:walldecor/bloc/library/library_event.dart';
import 'package:walldecor/bloc/library/libray_state.dart';
import 'package:walldecor/models/categorydetailes_model.dart';
import 'package:walldecor/models/all_library_model.dart';

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
                          onPressed: isLoading ? null : () {
                            final libraryName = controller.text.trim();
                            if (libraryName.isNotEmpty) {
                              onCreate(libraryName);
                              context.read<LibraryBloc>().add(
                                CreateLibraryEvent(
                                  token: "",
                                  libraryName: libraryName,
                                  id: "lib_${DateTime.now().millisecondsSinceEpoch}",
                                  urls: urls,
                                  user: user,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter a library name',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                          child: isLoading
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
                          onPressed: isLoading ? null : () {
                            final newLibraryName = controller.text.trim();
                            if (newLibraryName.isNotEmpty && newLibraryName != currentName) {
                              onCreate(newLibraryName);
                              context.read<LibraryBloc>().add(
                                RenameLibraryEvent(
                                  libraryId: libraryId,
                                  libraryName: newLibraryName,
                                ),
                              );
                            } else if (newLibraryName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter a library name',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            } else {
                              Navigator.pop(dialogContext);
                            }
                          },
                          child: isLoading
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
  final Urls urls;
  final User user;

  const SaveLibrarySheet({
    super.key,
    required this.urls,
    required this.user,
  });

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
                    ...libraries.map((library) => _DynamicLibraryItem(
                      library: library,
                      urls: widget.urls,
                      user: widget.user,
                    )),
                    const SizedBox(height: 10),
                    // Create new library button
                    ListTile(
                      leading: SvgPicture.asset(
                        'assets/svg/library.svg',
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Create new library',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        AddLibraryDialog(
                          context: context,
                          urls: widget.urls,
                          user: widget.user,
                          onCreate: (libraryName) {},
                        );
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
      leading: library.savedImage.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                library.savedImage.first.url.small,
                width: 30,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
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
      title: Text(
        library.name,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        '${library.totalImage} images',
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      onTap: () {
        // Add image to this library
        context.read<LibraryBloc>().add(
          UpdateLibraryEvent(
            libraryId: library.id,
            urls: urls,
            user: user,
          ),
        );
      },
    );
  }
}
