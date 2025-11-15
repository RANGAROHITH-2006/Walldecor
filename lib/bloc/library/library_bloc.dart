// bloc/library_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/library/libray_state.dart';
import 'package:walldecor/repositories/library_repository.dart';
import 'library_event.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final LibraryRepository repository;

  LibraryBloc(this.repository) : super(LibraryInitial()) {
    on<GetAllLibraryEvent>(_getAllLibrary);
    on<CreateLibraryEvent>((event, emit) async {
      emit(LibraryLoading());

      try {
        final response = await repository.createLibrary(
          event.token,
          libraryName: event.libraryName,
          id: event.id,
          urls: event.urls.toJson(),
          user: event.user.toJson(),
        );

        emit(LibrarySuccess(response));
      } catch (e) {
        emit(LibraryError(e.toString()));
      }
    });
    on<UpdateLibraryEvent>((event, emit) async {
      emit(LibraryLoading());

      try {
        final response = await repository.updateLibrary(
          event.libraryId,
          urls: event.urls,
          user: event.user,
        );

        emit(LibraryUpdateSuccess(response));
      } catch (e) {
        emit(LibraryError(e.toString()));
      }
    });
    on<RenameLibraryEvent>((event, emit) async {
      emit(LibraryLoading());

      try {
        final response = await repository.renameLibrary(
          event.libraryId,
          libraryName: event.libraryName,
        );

        emit(LibraryRenameSuccess(response));
      } catch (e) {
        emit(LibraryError(e.toString()));
      }
    });
  }

  
  Future<void> _getAllLibrary(
    GetAllLibraryEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());
    try {
      final data = await repository.fetchLibraryData();
      print("🔥 BLOC: Received ${data.length} items from repository");
      emit(LibraryLoaded(data));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }


}
