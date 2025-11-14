import 'package:walldecor/models/categorytrending_model.dart';
import 'package:walldecor/models/searchtendind_model.dart';

abstract class TrendingState {}

class TrendingInitial extends TrendingState {}

class TrendingLoading extends TrendingState {}


  class SearchTrendingLoaded extends TrendingState {
    final List<TrengingSearchModel> data;
    SearchTrendingLoaded(this.data);
  }

  class CategoryTrendingLoaded extends TrendingState {
    final List<CategorytrendingModel> data;
    CategoryTrendingLoaded(this.data);
  }
class TrendingError extends TrendingState {
  final String message;
  TrendingError(this.message);
}
