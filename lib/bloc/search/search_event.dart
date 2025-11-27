// bloc/library_event.dart
import 'package:equatable/equatable.dart';
abstract class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateSearchEvent extends SearchEvent {
  final String text;  

  CreateSearchEvent({
    required this.text,
  });

  @override
  List<Object?> get props => [text];
}

class SearchPaginatedEvent extends SearchEvent {
  final String text;
  final int page;
  final int limit;
  final bool isLoadMore;

  SearchPaginatedEvent({
    required this.text,
    this.page = 1,
    this.limit = 15,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [text, page, limit, isLoadMore];
}
