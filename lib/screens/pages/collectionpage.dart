import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:walldecor/bloc/collection/collection_bloc.dart';
import 'package:walldecor/bloc/collection/collection_event.dart';
import 'package:walldecor/bloc/collection/collection_state.dart';
import 'package:walldecor/repositories/collection_repository.dart';
import 'package:walldecor/screens/detailedscreens/collectiondetailspage.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  late CollectionBloc _collectionBloc;

  @override
  void initState() {
    super.initState();
    _collectionBloc = CollectionBloc(CollectionRepository());
    _collectionBloc.add(FetchCollectionEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      body: BlocBuilder<CollectionBloc, CollectionState>(
        bloc: _collectionBloc,
        builder: (context, state) {
          if (state is CollectionLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFEE5776)));
          } else if (state is CollectionLoaded) {
            final collections = state.data;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: StaggeredGrid.count(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: List.generate(collections.length, (index) {
                    return _buildStaggeredItem(
                      collections,
                      index,
                    );
                  }),
                ),
              ),
            );
          } else if (state is CollectionError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildStaggeredItem(collections, int index) {
    final positionInGroup = index % 6;
    int crossAxisCellCount;
    int mainAxisCellCount;

    switch (positionInGroup) {
      case 0:
        crossAxisCellCount = 3;
        mainAxisCellCount = 4;
        break;
      case 1:
      case 2:
        crossAxisCellCount = 3;
        mainAxisCellCount = 2;
        break;
      default:
        crossAxisCellCount = 6;
        mainAxisCellCount = 3;
    }

    return StaggeredGridTile.count(
      crossAxisCellCount: crossAxisCellCount,
      mainAxisCellCount: mainAxisCellCount,
      child: _buildImageCard(collections ,index, isLarge: positionInGroup == 0),
    );
  }

  Widget _buildImageCard(collections,index, {bool isLarge = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => CollectionDetailsPage(title: collections[index].title,id: collections[index].id),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black, blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                collections[index].coverPhoto.urls.regular,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF3A3D47),
                  child: Icon(Icons.image_not_supported,
                      color: const Color(0xFF868EAE), size: isLarge ? 50 : 30),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        collections[index].title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(color: Colors.black54, offset: Offset(0, 1), blurRadius: 2),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(isLarge ? 6 : 4),
                      child: Image.asset('assets/navbaricons/playicon.png',
                          width: 42, height: 19),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
