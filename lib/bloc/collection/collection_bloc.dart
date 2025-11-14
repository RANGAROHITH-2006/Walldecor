import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/collection/collection_event.dart';
import 'package:walldecor/bloc/collection/collection_state.dart';
import 'package:walldecor/repositories/collection_repository.dart';


class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final CollectionRepository repository;

  CollectionBloc(this.repository) : super(CollectionInitial()) {
    on<FetchCollectionEvent>(_onFetchCollection);
    on<FetchCollectionDetailsEvent>(_onFetchCollectionDetails);
  }

  Future<void> _onFetchCollection(
    FetchCollectionEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(CollectionLoading());
    try {
      final data = await repository.fetchCollectionData();
      emit(CollectionLoaded(data));
    } catch (e) {
      emit(CollectionError(e.toString()));
    }
  }


   Future<void> _onFetchCollectionDetails(
    FetchCollectionDetailsEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(CollectionLoading());
    try {
      final data = await repository.fetchCollectionDetailedData(event.CollectionId);
      emit(CollectionDetailsLoaded(data));
    } catch (e) {
      emit(CollectionError(e.toString()));
    }
  }

}
