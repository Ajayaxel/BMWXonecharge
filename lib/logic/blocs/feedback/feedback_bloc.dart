import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onecharge/data/repositories/feedback_repository.dart';
import 'package:onecharge/models/feedback_model.dart';

part 'feedback_event.dart';
part 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FeedbackRepository feedbackRepository;

  FeedbackBloc({required this.feedbackRepository}) : super(FeedbackInitial()) {
    on<SubmitFeedback>(_onSubmitFeedback);
  }

  Future<void> _onSubmitFeedback(
    SubmitFeedback event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackLoading());
    try {
      final response = await feedbackRepository.submitFeedback(event.request);
      if (response.success) {
        emit(FeedbackSuccess(response.message));
      } else {
        emit(FeedbackFailure(response.message));
      }
    } catch (e) {
      emit(FeedbackFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
