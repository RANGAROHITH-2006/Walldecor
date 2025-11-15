// bloc/library_event.dart
import 'package:equatable/equatable.dart';
abstract class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateSearchEvent extends SearchEvent {
  final String text;  

  CreateSearchEvent({
    required this.text,
  });

  @override
  List<Object?> get props => [text];
}
