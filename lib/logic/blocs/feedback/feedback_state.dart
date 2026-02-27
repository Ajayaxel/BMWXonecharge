part of 'feedback_bloc.dart';

abstract class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackSuccess extends FeedbackState {
  final String message;
  const FeedbackSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class FeedbackFailure extends FeedbackState {
  final String error;
  const FeedbackFailure(this.error);

  @override
  List<Object> get props => [error];
}
