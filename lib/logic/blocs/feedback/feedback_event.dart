part of 'feedback_bloc.dart';

abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object> get props => [];
}

class SubmitFeedback extends FeedbackEvent {
  final FeedbackRequest request;

  const SubmitFeedback(this.request);

  @override
  List<Object> get props => [request];
}
