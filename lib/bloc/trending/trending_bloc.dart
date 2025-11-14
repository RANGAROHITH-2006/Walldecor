import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/trending/trending_event.dart';
import 'package:walldecor/bloc/trending/trending_state.dart';
import 'package:walldecor/repositories/trending_repository.dart';

class TrendingBloc extends Bloc<TrendingEvent, TrendingState> {
  final TrendingRepository repository;

  TrendingBloc(this.repository) : super(TrendingInitial()) {
    on<FetchSearchTrendingEvent>(_onFetchSearchTrending);
    on<FetchCategoryTrendingEvent>(_onFetchCategoryTrending);
  }

  Future<void> _onFetchSearchTrending(
    FetchSearchTrendingEvent event,
    Emitter<TrendingState> emit,
  ) async {
    emit(TrendingLoading());
    try {
      final data = await repository.fetchTrendingSearchData();
      emit(SearchTrendingLoaded(data));
    } catch (e) {
      emit(TrendingError(e.toString()));
    }
  }


   Future<void> _onFetchCategoryTrending(
    FetchCategoryTrendingEvent event,
    Emitter<TrendingState> emit,
  ) async {
    emit(TrendingLoading());
    try {
      final data = await repository.fetchTrendingCategoryData();
      emit(CategoryTrendingLoaded(data));
    } catch (e) {
      emit(TrendingError(e.toString()));
    }
  }

}
