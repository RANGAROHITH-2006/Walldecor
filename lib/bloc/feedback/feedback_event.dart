import 'package:equatable/equatable.dart';

abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object?> get props => [];
}

class UpdateRatingEvent extends FeedbackEvent {
  final int rating;

  const UpdateRatingEvent(this.rating);

  @override
  List<Object?> get props => [rating];
}

class UpdateFeedbackOptionEvent extends FeedbackEvent {
  final String option;
  final bool isSelected;

  const UpdateFeedbackOptionEvent(this.option, this.isSelected);

  @override
  List<Object?> get props => [option, isSelected];
}

class UpdateCommentEvent extends FeedbackEvent {
  final String comment;

  const UpdateCommentEvent(this.comment);

  @override
  List<Object?> get props => [comment];
}

class SubmitFeedbackEvent extends FeedbackEvent {
  const SubmitFeedbackEvent();
}

class ResetFeedbackEvent extends FeedbackEvent {
  const ResetFeedbackEvent();
}