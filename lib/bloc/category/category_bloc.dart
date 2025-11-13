import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/category/category_event.dart';
import 'package:walldecor/bloc/category/category_state.dart';
import 'package:walldecor/repositories/category_repository.dart';


class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  CategoryBloc(this.repository) : super(CategoryInitial()) {
    on<FetchCategoryEvent>(_onFetchCategory);
    on<FetchCategoryDetailsEvent>(_onFetchCategoryDetails);
  }

  Future<void> _onFetchCategory(
    FetchCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final data = await repository.fetchCategoryData();
      emit(CategoryLoaded(data));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }


   Future<void> _onFetchCategoryDetails(
    FetchCategoryDetailsEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final data = await repository.fetchCategoryDetailedData(event.categoryId);
      emit(CategoryDetailsLoaded(data));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

}
