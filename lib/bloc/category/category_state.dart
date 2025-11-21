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

class CarouselWallpapersLoading extends CategoryState {}

class CarouselWallpapersLoaded extends CategoryState {
  final List<CategorydetailesModel> wallpapers;
  CarouselWallpapersLoaded(this.wallpapers);
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}
