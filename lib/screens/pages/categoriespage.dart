import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/category/category_bloc.dart';
import 'package:walldecor/bloc/category/category_event.dart';
import 'package:walldecor/bloc/category/category_state.dart';
import 'package:walldecor/bloc/trending/trending_bloc.dart';
import 'package:walldecor/bloc/trending/trending_event.dart';
import 'package:walldecor/bloc/trending/trending_state.dart';
import 'package:walldecor/models/category_model.dart';
import 'package:walldecor/repositories/category_repository.dart';
import 'package:walldecor/repositories/trending_repository.dart';
import 'package:walldecor/screens/detailedscreens/categorydetailespage.dart';

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
  const _CategoryView({super.key});

  @override
  State<_CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<_CategoryView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF25272F),
      child: SafeArea(
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
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state is TrendingError) {
                    return Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
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
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (state is CategoryLoaded) {
                    return Column(
                      children: state.data.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildCategoryCard(category),
                        );
                      }).toList(),
                    );
                  }

                  if (state is CategoryError) {
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Trending Pill UI ----------------
  Widget buildTrendingPill(item) {
    return Container(
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
    );
  }

  // ---------------- Category Card UI ----------------
  Widget _buildCategoryCard(CategoryModel category) {
    return GestureDetector(
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
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF2E3138),
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
            children: [
              Positioned.fill(
                child: Image.network(
                  category.coverPhoto.urls.regular,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF3A3D47),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Color(0xFF868EAE),
                    ),
                  ),
                ),
              ),
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
        ),
      ),
    );
  }
}
