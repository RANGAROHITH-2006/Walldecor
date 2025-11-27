// bloc/library_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/search/search_event.dart';
import 'package:walldecor/bloc/search/search_state.dart';
import 'package:walldecor/repositories/Search_repository.dart';


class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository repository;

  SearchBloc(this.repository) : super(SearchInitial()) {
    on<CreateSearchEvent>((event, emit) async {
      emit(SearchLoading());

      try {
        final response = await repository.SearchLibrary(
        text: event.text  
        );

        emit(SearchSuccess(response));
      } catch (e) {
        emit(SearchError(e.toString()));
      }
    });

    on<SearchPaginatedEvent>(_onSearchPaginated);
  }

  Future<void> _onSearchPaginated(
    SearchPaginatedEvent event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;
    
    if (event.isLoadMore) {
      // For loading more data
      if (currentState is SearchPaginatedSuccess) {
        emit(currentState.copyWith(isLoadingMore: true));
        
        try {
          final response = await repository.searchLibraryWithPagination(
            text: event.text,
            page: event.page,
            limit: event.limit,
          );
          
          List<dynamic> newResults = [];
          try {
            if (response.containsKey('results')) {
              newResults = response['results'] as List<dynamic>? ?? [];
            } else if (response is List) {
              newResults = response as List<dynamic>;
            }
          } catch (e) {
            print("Error parsing new search results: $e");
            newResults = [];
          }
          
          final allResults = [...currentState.results, ...newResults];
          final hasMoreData = newResults.length == event.limit;
          
          emit(SearchPaginatedSuccess(
            results: allResults,
            hasMoreData: hasMoreData,
            currentPage: event.page,
            searchText: event.text,
            isLoadingMore: false,
          ));
        } catch (e) {
          emit(currentState.copyWith(isLoadingMore: false));
          emit(SearchError(e.toString()));
        }
      }
    } else {
      // For initial search
      emit(SearchLoading());
      try {
        final response = await repository.searchLibraryWithPagination(
          text: event.text,
          page: event.page,
          limit: event.limit,
        );
        
        List<dynamic> results = [];
        try {
          if (response.containsKey('results')) {
            results = response['results'] as List<dynamic>? ?? [];
          } else if (response is List) {
            results = response as List<dynamic>;
          }
        } catch (e) {
          print("Error parsing search results: $e");
          results = [];
        }
        
        final hasMoreData = results.length == event.limit;
        
        emit(SearchPaginatedSuccess(
          results: results,
          hasMoreData: hasMoreData,
          currentPage: event.page,
          searchText: event.text,
        ));
      } catch (e) {
        emit(SearchError(e.toString()));
      }
    }
  }
}
