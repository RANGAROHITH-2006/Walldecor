import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/applist/applist_event.dart';
import 'package:walldecor/bloc/applist/applist_state.dart';
import 'package:walldecor/repositories/applist_repository.dart';

class ApplistBloc extends Bloc<ApplistEvent, ApplistState> {
  final ApplistRepository repository;

  ApplistBloc(this.repository) : super(ApplistInitial()) {
    on<FetchApplistEvent>(_onFetchApplist);
  }

  Future<void> _onFetchApplist(
    FetchApplistEvent event,
    Emitter<ApplistState> emit,
  ) async {
    emit(ApplistLoading());
    try {
      final data = await repository.fetchAppList();
      emit(ApplistLoaded(data));
    } catch (e) {
      emit(ApplistError(e.toString()));
    }
  }
}