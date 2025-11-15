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
  }
}
