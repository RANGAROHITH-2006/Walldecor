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
