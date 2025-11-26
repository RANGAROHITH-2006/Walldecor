import 'package:walldecor/models/category_model.dart';
import 'package:walldecor/models/categorydetailes_model.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> data;
  CategoryLoaded(this.data);
}

class CategoryDetailsLoading extends CategoryState {
  final List<CategoryModel> categories;
  CategoryDetailsLoading(this.categories);
}

class CategoryDetailsLoaded extends CategoryState {
  final List<CategoryModel> categories;
  final List<CategorydetailesModel> data;
  CategoryDetailsLoaded(this.categories, this.data);
}

class CategoryDetailsPaginatedLoaded extends CategoryState {
  final List<CategoryModel> categories;
  final List<CategorydetailesModel> data;
  final bool hasMoreData;
  final int currentPage;
  final bool isLoadingMore;

  CategoryDetailsPaginatedLoaded({
    required this.categories,
    required this.data,
    required this.hasMoreData,
    required this.currentPage,
    this.isLoadingMore = false,
  });

  CategoryDetailsPaginatedLoaded copyWith({
    List<CategoryModel>? categories,
    List<CategorydetailesModel>? data,
    bool? hasMoreData,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return CategoryDetailsPaginatedLoaded(
      categories: categories ?? this.categories,
      data: data ?? this.data,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class CarouselWallpapersLoading extends CategoryState {}

class CarouselWallpapersLoaded extends CategoryState {
  final List<CategorydetailesModel> wallpapers;
  CarouselWallpapersLoaded(this.wallpapers);
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}
