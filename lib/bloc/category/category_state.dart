import 'package:walldecor/models/category_model.dart';
import 'package:walldecor/models/categorydetailes_model.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> data;
  CategoryLoaded(this.data);
}

class CategoryDetailsLoaded extends CategoryState {
  final List<CategorydetailesModel> data;
  CategoryDetailsLoaded(this.data);
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}
