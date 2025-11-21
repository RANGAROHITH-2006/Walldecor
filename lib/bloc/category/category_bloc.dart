import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/category/category_event.dart';
import 'package:walldecor/bloc/category/category_state.dart';
import 'package:walldecor/models/category_model.dart';
import 'package:walldecor/repositories/category_repository.dart';


class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;
  List<CategoryModel> _cachedCategories = [];

  CategoryBloc(this.repository) : super(CategoryInitial()) {
    on<FetchCategoryEvent>(_onFetchCategory);
    on<FetchCategoryDetailsEvent>(_onFetchCategoryDetails);
    on<FetchCarouselWallpapersEvent>(_onFetchCarouselWallpapers);
  }

  Future<void> _onFetchCategory(
    FetchCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final data = await repository.fetchCategoryData();
      _cachedCategories = data;
      emit(CategoryLoaded(data));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }


   Future<void> _onFetchCategoryDetails(
    FetchCategoryDetailsEvent event,
    Emitter<CategoryState> emit,
  ) async {
    if (_cachedCategories.isNotEmpty) {
      emit(CategoryDetailsLoading(_cachedCategories));
    }
    try {
      final data = await repository.fetchCategoryDetailedData(event.categoryId);
      emit(CategoryDetailsLoaded(_cachedCategories, data));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onFetchCarouselWallpapers(
    FetchCarouselWallpapersEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CarouselWallpapersLoading());
    try {
      final wallpapers = await repository.fetchCarouselWallpapers(
        event.categorySlug, 
        limit: event.limit
      );
      emit(CarouselWallpapersLoaded(wallpapers));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

}
