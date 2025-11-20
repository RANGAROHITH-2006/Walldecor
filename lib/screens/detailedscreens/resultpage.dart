import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:walldecor/bloc/library/library_bloc.dart';
import 'package:walldecor/bloc/favorite/favorite_bloc.dart';
import 'package:walldecor/bloc/favorite/favorite_event.dart';
import 'package:walldecor/bloc/favorite/favorite_state.dart';
import 'package:walldecor/models/categorydetailes_model.dart';
import 'package:walldecor/repositories/library_repository.dart';
import 'package:walldecor/repositories/favorite_repository.dart';
import 'package:walldecor/screens/widgets/diolog.dart';

class Resultpage extends StatefulWidget {
  final Urls urls;
  final User user;

  const Resultpage({super.key, required this.urls, required this.user});

  @override
  State<Resultpage> createState() => _ResultpageState();
}

class _ResultpageState extends State<Resultpage> {
  OverlayEntry? _popup;
  final LayerLink _layerLink = LayerLink();

  Future<void> shareImage(String imageUrl) async {
    try {
      // 1. Download the image
      final response = await http.get(Uri.parse(imageUrl));

      // 2. Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/shared_image.jpg';
      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // 3. Share the image
      await Share.shareXFiles([XFile(filePath)], text: "Check this image!");
    } catch (e) {
      print("❌ Error sharing image: $e");
    }
  }


  void _removePopup() {
    _popup?.remove();
    _popup = null;
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.urls.regular;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LibraryBloc(LibraryRepository())),
        BlocProvider(
          create:
              (context) =>
                  FavoriteBloc(favoriteRepository: FavoriteRepository()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<FavoriteBloc, FavoriteState>(
            listener: (context, state) {
              if (state is FavoriteAddSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is FavoriteAddError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: const Color(0xFFEE5776),
                  ),
                );
              }
            },
          ),
        ],
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xFF25272F),
          appBar: AppBar(
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 18,
              ),
            ),
            backgroundColor: const Color(0xFF25272F),
            title: const Text(
              'Show Result',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  _removePopup();
                  context.read<FavoriteBloc>().add(
                    AddToFavoriteEvent(
                      id: widget.user.id,
                      urls: widget.urls.toJson(),
                      user: widget.user.toJson(),
                    ),
                  );
                },
                child: Row(
                  children: const [
                    Icon(Icons.favorite_border, color: Colors.white),
                    SizedBox(width: 16),
                  ],
                ),
              ),
            ],
          ),

          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                    height: 544,
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
                const SizedBox(height: 16),
                const Text(
                  'Unsplash In Collaboration with Danial Miralev',
                  style: TextStyle(color: Color(0xFF4A4D57), fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Bottom Action Container
                Container(
                  width: 311,
                  height: 61,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEE5776),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            AddLibraryDialog(
                              context: context,
                              urls: widget.urls,
                              user: widget.user,
                              onCreate: (libraryName) {},
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/svg/library.svg',
                            width: 28,
                            height: 28,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: const Color(0xFF25272F),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder:
                                  (context) => SaveLibrarySheet(
                                    urls: widget.urls,
                                    user: widget.user,
                                  ),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/svg/download.svg',
                            width: 36,
                            height: 36,
                          ),
                        ),
                        CompositedTransformTarget(
                          link: _layerLink,
                          child: GestureDetector(
                            onTap: () => shareImage(widget.urls.regular),
                            child: SvgPicture.asset(
                              'assets/svg/share.svg',
                              width: 28,
                              height: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
