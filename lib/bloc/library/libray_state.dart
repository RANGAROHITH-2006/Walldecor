// bloc/library_state.dart
import 'package:equatable/equatable.dart';

abstract class LibraryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibrarySuccess extends LibraryState {
  final Map<String, dynamic> data;
  LibrarySuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class LibraryError extends LibraryState {
  final String message;
  LibraryError(this.message);

  @override
  List<Object?> get props => [message];
}
