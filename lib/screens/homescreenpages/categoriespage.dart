import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:walldecor/bloc/category/category_bloc.dart';
import 'package:walldecor/bloc/category/category_event.dart';
import 'package:walldecor/bloc/category/category_state.dart';
import 'package:walldecor/bloc/connectivity/connectivity_bloc.dart';
import 'package:walldecor/bloc/connectivity/connectivity_event.dart';
import 'package:walldecor/bloc/connectivity/connectivity_state.dart';
import 'package:walldecor/bloc/trending/trending_bloc.dart';
import 'package:walldecor/bloc/trending/trending_event.dart';
import 'package:walldecor/bloc/trending/trending_state.dart';
import 'package:walldecor/models/category_model.dart';
import 'package:walldecor/repositories/category_repository.dart';
import 'package:walldecor/repositories/trending_repository.dart';
import 'package:walldecor/screens/detailedscreens/categorydetailespage.dart';
import 'package:walldecor/screens/widgets/no_internet_widget.dart';

class Categorypage extends StatelessWidget {
  const Categorypage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              CategoryBloc(CategoryRepository())..add(FetchCategoryEvent()),
        ),
        BlocProvider(
          create: (_) =>
              TrendingBloc(TrendingRepository())..add(FetchCategoryTrendingEvent()),
        ),
      ],
      child: const _CategoryView(),
    );
  }
}

class _CategoryView extends StatefulWidget {
  // ignore: unused_element_parameter
  const _CategoryView({super.key});

  @override
  State<_CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<_CategoryView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF25272F),
      child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, connectivityState) {
          if (connectivityState is ConnectivityOffline) {
            return NoInternetWidget(
              onRetry: () {
                context.read<ConnectivityBloc>().add(CheckConnectivity());
              },
            );
          }
          
          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------- Trending ----------------
                  const Text(
                    'Trending',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  BlocBuilder<TrendingBloc, TrendingState>(
                    builder: (context, state) {
                      if (state is TrendingLoading) {
                        return const SizedBox(
                          height: 60,
                          child: Center(child: CircularProgressIndicator(color: Color(0xFFEE5776))),
                        );
                      }

                      if (state is TrendingError) {
                        return SizedBox(
                          height: 60,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.wifi_off,
                                  color: Color(0xFF868EAE),
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Unable to load trending',
                                  style: const TextStyle(
                                    color: Color(0xFF868EAE),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is CategoryTrendingLoaded) {
                        return SizedBox(
                          height: 60,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.data.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final item = state.data[index];
                              return buildTrendingPill(item);
                            },
                          ),
                        );
                      }

                      return const SizedBox();
                    },
                  ),

                  const SizedBox(height: 20),

                  // ---------------- Categories ----------------
                  const Text(
                    'All Categories',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: Color(0xFFEE5776)),
                        );
                      }

                      if (state is CategoryLoaded) {
                        return Column(
                          children: state.data.map((category) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: ParallaxCategoryItem(
                                category: category,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CategoryDetailsPage(
                                        title: category.title,
                                        id: category.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      }

                      if (state is CategoryError) {
                        return Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.wifi_off,
                                color: Color(0xFF868EAE),
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Unable to load categories',
                                style: TextStyle(
                                  color: Color(0xFF868EAE),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  context.read<CategoryBloc>().add(FetchCategoryEvent());
                                },
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(
                                    color: Color(0xFFEE5776),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- Trending Pill UI ----------------
  Widget buildTrendingPill(item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailsPage(
              title: item.title,
              id: item.id,
            ),
          ),
        );
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF2E3138),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A3D47)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.coverPhoto.urls.small,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 40,
                  height: 40,
                  color: const Color(0xFF3A3D47),
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Color(0xFF868EAE),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= PARALLAX CATEGORY ITEM =================

class ParallaxCategoryItem extends StatelessWidget {
  const ParallaxCategoryItem({
    super.key,
    required this.category,
    required this.onTap,
  });

  final CategoryModel category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Parallax background
              CategoryParallax(
                child: CachedNetworkImage(

                  imageUrl: category.coverPhoto.urls.regular,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFF3A3D47),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFEE5776),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFF3A3D47),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Color(0xFF868EAE),
                    ),
                  ),
                ),
              ),
              // Gradient overlay
              // Container(
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       begin: Alignment.topCenter,
              //       end: Alignment.bottomCenter,
              //       colors: [
              //         Colors.transparent,
              //         Colors.black.withOpacity(0.7),
              //       ],
              //       stops: const [0.5, 1.0],
              //     ),
              //   ),
              // ),
              // Content
              Stack(
                children: [
                  Positioned(
                    left: 16,
                    bottom: 14,
                    child: Text(
                      category.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 8,
                    child: Image.asset(
                      'assets/navbaricons/playicon.png',
                      width: 42,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= CUSTOM PARALLAX WIDGET =================

class CategoryParallax extends StatelessWidget {
  CategoryParallax({
    super.key,
    required this.child,
  });

  final Widget child;
  final GlobalKey _backgroundImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final scrollable = Scrollable.of(context);

    return Flow(
      delegate: ParallaxFlowDelegate(
        scrollable: scrollable,
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey,
      ),
      children: [
        KeyedSubtree(
          key: _backgroundImageKey,
          child: child,
        ),
      ],
    );
  }
}


// ================= PARALLAX FLOW DELEGATE =================

class ParallaxFlowDelegate extends FlowDelegate {
  ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
  }) : super(repaint: scrollable.position);

  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(width: constraints.maxWidth);
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;

    final listItemOffset = listItemBox.localToGlobal(
      listItemBox.size.centerLeft(Offset.zero),
      ancestor: scrollableBox,
    );

    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction =
        (listItemOffset.dy / viewportDimension).clamp(0.0, 1.0);

    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);

    final backgroundSize =
        (backgroundImageKey.currentContext!.findRenderObject() as RenderBox)
            .size;

    final listItemSize = context.size;

    final childRect =
        verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    context.paintChild(
      0,
      transform:
          Transform.translate(offset: Offset(0.0, childRect.top)).transform,
    );
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}
