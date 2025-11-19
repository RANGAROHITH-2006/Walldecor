import 'package:equatable/equatable.dart';

class FeedbackState extends Equatable {
  final int rating;
  final bool option1;
  final bool option2;
  final bool option3;
  final bool option4;
  final String comment;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? errorMessage;

  const FeedbackState({
    this.rating = 5,
    this.option1 = false,
    this.option2 = false,
    this.option3 = false,
    this.option4 = false,
    this.comment = '',
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.errorMessage,
  });

  FeedbackState copyWith({
    int? rating,
    bool? option1,
    bool? option2,
    bool? option3,
    bool? option4,
    String? comment,
    bool? isSubmitting,
    bool? isSubmitted,
    String? errorMessage,
  }) {
    return FeedbackState(
      rating: rating ?? this.rating,
      option1: option1 ?? this.option1,
      option2: option2 ?? this.option2,
      option3: option3 ?? this.option3,
      option4: option4 ?? this.option4,
      comment: comment ?? this.comment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errorMessage: errorMessage,
    );
  }

  bool get showFeedbackForm => rating > 0 && rating < 4;

  @override
  List<Object?> get props => [
    rating,
    option1,
    option2,
    option3,
    option4,
    comment,
    isSubmitting,
    isSubmitted,
    errorMessage,
  ];
}