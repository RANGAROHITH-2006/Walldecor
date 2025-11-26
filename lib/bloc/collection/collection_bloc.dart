import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/collection/collection_event.dart';
import 'package:walldecor/bloc/collection/collection_state.dart';
import 'package:walldecor/repositories/collection_repository.dart';


class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final CollectionRepository repository;

  CollectionBloc(this.repository) : super(CollectionInitial()) {
    on<FetchCollectionEvent>(_onFetchCollection);
    on<FetchCollectionDetailsEvent>(_onFetchCollectionDetails);
    on<FetchCollectionDetailsPaginatedEvent>(_onFetchCollectionDetailsPaginated);
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

  Future<void> _onFetchCollectionDetailsPaginated(
    FetchCollectionDetailsPaginatedEvent event,
    Emitter<CollectionState> emit,
  ) async {
    final currentState = state;
    
    if (event.isLoadMore) {
      // For loading more data
      if (currentState is CollectionDetailsPaginatedLoaded) {
        emit(currentState.copyWith(isLoadingMore: true));
        
        try {
          final newData = await repository.fetchCollectionDetailedDataWithPagination(
            event.collectionId,
            page: event.page,
            limit: event.limit,
          );
          
          final allData = [...currentState.data, ...newData];
          final hasMoreData = newData.length == event.limit;
          
          emit(CollectionDetailsPaginatedLoaded(
            data: allData,
            hasMoreData: hasMoreData,
            currentPage: event.page,
            isLoadingMore: false,
          ));
        } catch (e) {
          emit(currentState.copyWith(isLoadingMore: false));
          emit(CollectionError(e.toString()));
        }
      }
    } else {
      // For initial load
      emit(CollectionLoading());
      try {
        final data = await repository.fetchCollectionDetailedDataWithPagination(
          event.collectionId,
          page: event.page,
          limit: event.limit,
        );
        
        final hasMoreData = data.length == event.limit;
        
        emit(CollectionDetailsPaginatedLoaded(
          data: data,
          hasMoreData: hasMoreData,
          currentPage: event.page,
        ));
      } catch (e) {
        emit(CollectionError(e.toString()));
      }
    }
  }
}
