// bloc/library_state.dart
import 'package:equatable/equatable.dart';
import 'package:walldecor/models/all_library_model.dart';

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

class LibraryLoaded extends LibraryState {
  final List<AllLibraryModel> data;
  LibraryLoaded(this.data);
}

class LibraryUpdateSuccess extends LibraryState {
  final Map<String, dynamic> data;
  LibraryUpdateSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class LibraryRenameSuccess extends LibraryState {
  final Map<String, dynamic> data;
  LibraryRenameSuccess(this.data);

  @override
  List<Object?> get props => [data];
}
