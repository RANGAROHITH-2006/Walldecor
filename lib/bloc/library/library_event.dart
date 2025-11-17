// bloc/library_event.dart
import 'package:equatable/equatable.dart';
import 'package:walldecor/models/categorydetailes_model.dart';

abstract class LibraryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateLibraryEvent extends LibraryEvent {
  final String token;
  final String libraryName;
  final String id;
  final Urls urls;
  final User user;

  CreateLibraryEvent({
    required this.token,
    required this.libraryName,
    required this.id,
    required this.urls,
    required this.user,
  });



  @override
  List<Object?> get props => [token, libraryName, id, urls, user];
}


class GetAllLibraryEvent extends LibraryEvent {}

class UpdateLibraryEvent extends LibraryEvent {
  final String libraryId;
  final Urls urls;
  final User user;

  UpdateLibraryEvent({
    required this.libraryId,
    required this.urls,
    required this.user,
  });

  @override
  List<Object?> get props => [libraryId, urls, user];
}

class RenameLibraryEvent extends LibraryEvent {
  final String libraryId;
  final String libraryName;

  RenameLibraryEvent({
    required this.libraryId,
    required this.libraryName,
  });

  @override
  List<Object?> get props => [libraryId, libraryName];
}

class GetAllLibraryDetailsEvent extends LibraryEvent {
  final String libraryId;

  GetAllLibraryDetailsEvent(this.libraryId);
}

class DeleteLibraryEvent extends LibraryEvent {
  final String libraryId;
  final String libraryName;

  DeleteLibraryEvent({
    required this.libraryId,
    required this.libraryName,
  });

  @override
  List<Object?> get props => [libraryId, libraryName];
}
