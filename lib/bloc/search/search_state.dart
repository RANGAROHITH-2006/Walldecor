// bloc/library_state.dart
import 'package:equatable/equatable.dart';

abstract class SearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final Map<String, dynamic> data;
  SearchSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class SearchPaginatedSuccess extends SearchState {
  final List<dynamic> results;
  final bool hasMoreData;
  final int currentPage;
  final bool isLoadingMore;
  final String searchText;

  SearchPaginatedSuccess({
    required this.results,
    required this.hasMoreData,
    required this.currentPage,
    required this.searchText,
    this.isLoadingMore = false,
  });

  SearchPaginatedSuccess copyWith({
    List<dynamic>? results,
    bool? hasMoreData,
    int? currentPage,
    bool? isLoadingMore,
    String? searchText,
  }) {
    return SearchPaginatedSuccess(
      results: results ?? this.results,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [results, hasMoreData, currentPage, isLoadingMore, searchText];
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
