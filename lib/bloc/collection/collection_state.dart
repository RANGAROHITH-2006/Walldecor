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

class CollectionError extends CollectionState {
  final String message;
  CollectionError(this.message);
}
