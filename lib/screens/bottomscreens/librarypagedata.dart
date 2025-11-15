import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:walldecor/bloc/library/library_bloc.dart';
import 'package:walldecor/bloc/library/library_event.dart';
import 'package:walldecor/bloc/library/libray_state.dart';
import 'package:walldecor/screens/static/diolog.dart';
import 'package:walldecor/screens/static/noresult.dart';

class LibrarypageData extends StatefulWidget {
  const LibrarypageData({super.key});

  @override
  State<LibrarypageData> createState() => _LibrarypageDataState();
}

class _LibrarypageDataState extends State<LibrarypageData> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🔥 LibrarypageData: Triggering GetAllLibraryEvent');
    context.read<LibraryBloc>().add(GetAllLibraryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF25272F),
        elevation: 0,
        leading: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: 16,
        ),
        titleSpacing: 0,
        title: const Text(
          'Image Library',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        
      ),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          print('🔥 LibrarypageData: Current state - ${state.runtimeType}');
          
          if (state is LibraryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LibraryError) {
            print('🔥 LibraryError: ${state.message}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LibraryBloc>().add(GetAllLibraryEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is LibraryLoaded) {
            final data = state.data;
            print('🔥 LibraryLoaded: ${data.length} items');

            if (data.isEmpty) {
              return Noresult();
            }
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.81,
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];

                final title = item.name;
                final totalImages = item.totalImage;
                
                // Check if savedImage list is not empty before accessing first
                String imageUrl = '';
                if (item.savedImage.isNotEmpty) {
                  imageUrl = item.savedImage.first.url.regular;
                }

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF303238),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                        ),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                height: 148,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 120,
                                  width: double.infinity,
                                  color: Colors.black26,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white54,
                                  ),
                                ),
                              )
                            : Container(
                                height: 120,
                                width: double.infinity,
                                color: Color(0xFF303238),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white54,
                                ),
                              ),
                      ),

                      // Title + Edit Icon
                       Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 6.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Texts
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$totalImages Images',
                              style: const TextStyle(
                                color: Color(0xFF868EAE),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            EditlibraryDialog(
                              context: context,
                              libraryId: item.id,
                              currentName: item.name,
                              onCreate: (libraryName) {},
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/svg/Pen.svg',
                            width: 22,
                            height: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                    ],
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
