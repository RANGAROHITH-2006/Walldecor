import 'package:walldecor/models/collection_model.dart';
import 'package:walldecor/models/collectiondetailes_model.dart';

abstract class CollectionState {}

class CollectionInitial extends CollectionState {}

class CollectionLoading extends CollectionState {}

class CollectionLoaded extends CollectionState {
  final List<CollectionModel> data;
  CollectionLoaded(this.data);
}

class CollectionDetailsLoaded extends CollectionState {
  final List<CollectiondetailesModel> data;
  CollectionDetailsLoaded(this.data);
}

class CollectionDetailsPaginatedLoaded extends CollectionState {
  final List<CollectiondetailesModel> data;
  final bool hasMoreData;
  final int currentPage;
  final bool isLoadingMore;

  CollectionDetailsPaginatedLoaded({
    required this.data,
    required this.hasMoreData,
    required this.currentPage,
    this.isLoadingMore = false,
  });

  CollectionDetailsPaginatedLoaded copyWith({
    List<CollectiondetailesModel>? data,
    bool? hasMoreData,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return CollectionDetailsPaginatedLoaded(
      data: data ?? this.data,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class CollectionError extends CollectionState {
  final String message;
  CollectionError(this.message);
}
