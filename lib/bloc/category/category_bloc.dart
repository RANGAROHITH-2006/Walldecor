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
    on<FetchCategoryDetailsPaginatedEvent>(_onFetchCategoryDetailsPaginated);
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

  Future<void> _onFetchCategoryDetailsPaginated(
    FetchCategoryDetailsPaginatedEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;
    
    if (event.isLoadMore) {
      // For loading more data
      if (currentState is CategoryDetailsPaginatedLoaded) {
        emit(currentState.copyWith(isLoadingMore: true));
        
        try {
          final newData = await repository.fetchCategoryDetailedDataWithPagination(
            event.categoryId,
            page: event.page,
            limit: event.limit,
          );
          
          final allData = [...currentState.data, ...newData];
          final hasMoreData = newData.length == event.limit;
          
          emit(CategoryDetailsPaginatedLoaded(
            categories: currentState.categories,
            data: allData,
            hasMoreData: hasMoreData,
            currentPage: event.page,
            isLoadingMore: false,
          ));
        } catch (e) {
          emit(currentState.copyWith(isLoadingMore: false));
          emit(CategoryError(e.toString()));
        }
      }
    } else {
      // For initial load
      if (_cachedCategories.isNotEmpty) {
        emit(CategoryDetailsLoading(_cachedCategories));
      }
      try {
        final data = await repository.fetchCategoryDetailedDataWithPagination(
          event.categoryId,
          page: event.page,
          limit: event.limit,
        );
        
        final hasMoreData = data.length == event.limit;
        
        emit(CategoryDetailsPaginatedLoaded(
          categories: _cachedCategories,
          data: data,
          hasMoreData: hasMoreData,
          currentPage: event.page,
        ));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
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
