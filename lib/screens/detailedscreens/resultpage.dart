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
  final String id;
  final Urls urls;
  final User user;

  const Resultpage({super.key, required this.id, required this.urls, required this.user});
  @override
  State<Resultpage> createState() => _ResultpageState();
}

class _ResultpageState extends State<Resultpage> {
  OverlayEntry? _popup;
  final LayerLink _layerLink = LayerLink();
  bool _isFavorited = false;
  bool show = false;
  late final FavoriteBloc _favoriteBloc;

  Future<void> shareImage(String imageUrl) async {
    final String link = "https://privacy.freephotos.wibes.co.in/privacy_policy";
    try {
      // 1. Download the image
      final response = await http.get(Uri.parse(imageUrl));

      // 2. Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/shared_image.jpg';
      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // 3. Share the image
      await Share.shareXFiles([XFile(filePath)], text: "check out this image!\nApp Name: WallDecor \nApp Link: $link");
      
      print("✅ Image shared successfully");
    } catch (e) {
      print("❌ Error sharing image: $e");
    }
  }


  void _removePopup() {
    _popup?.remove();
    _popup = null;
  }

void shareTap(){
  setState(() {
    show = !show;
  });
}

  @override
  void initState() {
    super.initState();
    print('🔥 ResultPage: Initializing with user ID: ${widget.user.id}');
    
    // Initialize the FavoriteBloc
    _favoriteBloc = FavoriteBloc(favoriteRepository: FavoriteRepository());
    
    // Check if current image is favorited
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔥 ResultPage: Dispatching GetAllFavoritesEvent');
      _favoriteBloc.add(GetAllFavoritesEvent());
    });
  }

  @override
  void dispose() {
    _favoriteBloc.close();
    super.dispose();
  }  void _checkIfFavorited(List favorites) {
    
    bool isFav = favorites.any((fav) {
      return fav.favoriteImageId == widget.user.id;
    });
    
    if (mounted && _isFavorited != isFav) {
      setState(() {
        _isFavorited = isFav;
      });
    } else {
      print('🔥 ResultPage: No state change needed - already $_isFavorited');
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.urls.regular;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LibraryBloc(LibraryRepository())),
        BlocProvider<FavoriteBloc>.value(
          value: _favoriteBloc,
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<FavoriteBloc, FavoriteState>(
            listener: (context, state) {
              print('🔥 ResultPage: Received FavoriteBloc state: ${state.runtimeType}');
              
              if (state is FavoriteAddSuccess) {
                print('🔥 ResultPage: Favorite add success - ${state.message}');
                setState(() {
                  _isFavorited = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (state is FavoriteAddError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.orange, 
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (state is FavoriteStatusChecked) {
                setState(() {
                  _isFavorited = state.isFavorited;
                });
              } else if (state is FavoritesLoaded) {
                _checkIfFavorited(state.favorites);
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
              style: TextStyle(color: Colors.white,fontSize: 18),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  _removePopup();
                  // Always try to add to favorites - let the API handle duplicates
                  _favoriteBloc.add(
                    AddToFavoriteEvent(
                      id: widget.user.id,
                      urls: widget.urls.toJson(),
                      user: widget.user.toJson(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      _isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorited ? const Color(0xFFEE5776) : Colors.white,
                    ),
                    const SizedBox(width: 16),
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
                  child: Center(
                    child: Image.network(
                      image,
                      fit: BoxFit.fill,
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
                          child: Icon( Icons.library_add, color: Colors.white, size: 28)
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
                                    id: widget.id,
                                    urls: widget.urls,
                                    user: widget.user,
                                  ),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/svg/savelibrary.svg',
                            width: 36,
                            height: 36,
                          ),
                        ),
                        CompositedTransformTarget(
                          link: _layerLink,
                          child: GestureDetector(
                            onTap: () {
                                shareTap();
                                if(show){
                                  shareImage(widget.urls.full);
                                }
                            },
                            child: SvgPicture.asset(
                              'assets/svg/share2.svg',
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
