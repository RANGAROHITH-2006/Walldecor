import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/favorite/favorite_bloc.dart';
import 'package:walldecor/bloc/favorite/favorite_event.dart';
import 'package:walldecor/bloc/favorite/favorite_state.dart';
import 'package:walldecor/models/categorydetailes_model.dart';
import 'package:walldecor/screens/detailedscreens/resultpage.dart';
import 'package:walldecor/screens/widgets/noresult.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FavoriteBloc>().add(GetAllFavoritesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (state is FavoriteLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEE5776)),
            );
          } else if (state is FavoritesLoaded) {
            final favorites = state.favorites;

            if (favorites.isEmpty) {
              return const Noresult();
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
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final item = favorites[index];
                  return GestureDetector(
                    onTap: () {
                      // Create proper Urls and User objects from favorite data
                      final urls = Urls(
                        full: item.url?.full ?? '',
                        regular: item.url?.regular ?? '',
                        small: item.url?.small ?? '',
                      );

                      final user = User(
                        id: item.imageOwner?.id ?? '',
                        username: item.imageOwner?.username ?? '',
                        name: item.imageOwner?.name ?? '',
                        firstName: item.imageOwner?.firstName ?? '',
                        lastName: item.imageOwner?.lastName ?? '',
                        profileLink: item.imageOwner?.profileLink ?? '',
                        profileImage: item.imageOwner?.profileImage ?? '',
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => Resultpage(id: item.id ?? '', urls: urls, user: user),
                        ),
                      );
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
                                item.url?.small ?? '',
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
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is FavoriteError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Color(0xFFEE5776)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FavoriteBloc>().add(GetAllFavoritesEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Loading favorites...',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  CircularProgressIndicator(color: Color(0xFFEE5776)),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
