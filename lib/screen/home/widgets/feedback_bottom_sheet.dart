import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/const/onebtn.dart';
import 'package:onecharge/logic/blocs/feedback/feedback_bloc.dart';
import 'package:onecharge/models/feedback_model.dart';
import 'package:onecharge/utils/toast_utils.dart';

class FeedbackBottomSheet extends StatefulWidget {
  final int? ticketId;

  const FeedbackBottomSheet({super.key, this.ticketId});

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers for comments
  final TextEditingController _satisfactionCommentController =
      TextEditingController();
  final TextEditingController _expectationsCommentController =
      TextEditingController();
  final TextEditingController _durabilityCommentController =
      TextEditingController();
  final TextEditingController _likedMostController = TextEditingController();
  final TextEditingController _improveSuggestionsController =
      TextEditingController();

  // Scores and Booleans
  int _overallQualityRating = 5;
  int _chargingSpeedRating = 5;
  bool _staffHelpfulProfessional = true;
  int _recommendationScore = 10;
  int _appExperienceScore = 10;
  bool _bookingProcessEasyClear = true;

  @override
  void dispose() {
    _pageController.dispose();
    _satisfactionCommentController.dispose();
    _expectationsCommentController.dispose();
    _durabilityCommentController.dispose();
    _likedMostController.dispose();
    _improveSuggestionsController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (widget.ticketId == null) {
      ToastUtils.showToast(context, "Ticket ID is missing", isError: true);
      return;
    }

    final request = FeedbackRequest(
      ticketId: widget.ticketId!,
      overallSatisfactionComment: _satisfactionCommentController.text,
      chargerExpectationsComment: _expectationsCommentController.text,
      overallQualityRating: _overallQualityRating,
      chargingSpeedRating: _chargingSpeedRating,
      chargerDurabilityComment: _durabilityCommentController.text,
      staffHelpfulProfessional: _staffHelpfulProfessional,
      recommendationScore: _recommendationScore,
      likedMost: _likedMostController.text,
      improveSuggestions: _improveSuggestionsController.text,
      appExperienceScore: _appExperienceScore,
      bookingProcessEasyClear: _bookingProcessEasyClear,
    );

    context.read<FeedbackBloc>().add(SubmitFeedback(request));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FeedbackBloc, FeedbackState>(
      listener: (context, state) {
        if (state is FeedbackSuccess) {
          ToastUtils.showToast(context, state.message);
          Navigator.pop(context);
        } else if (state is FeedbackFailure) {
          ToastUtils.showToast(context, state.error, isError: true);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [_buildStep1(), _buildStep2(), _buildStep3()],
                ),
              ),
              const SizedBox(height: 20),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Overall Satisfaction",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lufga',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          _buildQuestion(
            "How satisfied are you with your mobile ev charger service?",
            isTextArea: true,
            controller: _satisfactionCommentController,
          ),
          const SizedBox(height: 24),
          _buildQuestion(
            "Did the charger meet your expectations?",
            isTextArea: true,
            controller: _expectationsCommentController,
          ),
          const SizedBox(height: 24),
          _buildQuestion(
            "How would you rate the overall quality?",
            isRating: true,
            rating: _overallQualityRating,
            onRatingChanged: (val) =>
                setState(() => _overallQualityRating = val),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Product Quality",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lufga',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          _buildQuestion(
            "How would you rate the charging speed?",
            isRating: true,
            rating: _chargingSpeedRating,
            onRatingChanged: (val) =>
                setState(() => _chargingSpeedRating = val),
          ),
          const SizedBox(height: 24),
          _buildQuestion(
            "Does the charger feel durable?",
            isTextArea: true,
            controller: _durabilityCommentController,
          ),
          const SizedBox(height: 32),
          const Text(
            "Service Experience",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lufga',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          _buildQuestion(
            "Was our staff helpful and professional?",
            isYesNo: true,
            isYes: _staffHelpfulProfessional,
            onYesNoChanged: (val) =>
                setState(() => _staffHelpfulProfessional = val),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recommendation",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lufga',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          _buildQuestion(
            "How likely are you to recommend us to others? (0-10)",
            isScore: true,
            score: _recommendationScore,
            onScoreChanged: (val) => setState(() => _recommendationScore = val),
          ),
          const SizedBox(height: 16),
          _buildQuestion(
            "What did you like most?",
            isTextArea: true,
            controller: _likedMostController,
          ),
          const SizedBox(height: 16),
          _buildQuestion(
            "What can we improve?",
            isTextArea: true,
            controller: _improveSuggestionsController,
          ),
          const SizedBox(height: 24),
          const Text(
            "App Experience",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lufga',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestion(
            "Rate your app experience (0-10)",
            isScore: true,
            score: _appExperienceScore,
            onScoreChanged: (val) => setState(() => _appExperienceScore = val),
          ),
          const SizedBox(height: 24),
          _buildQuestion(
            "Was the booking process easy and clear?",
            isYesNo: true,
            isYes: _bookingProcessEasyClear,
            onYesNoChanged: (val) =>
                setState(() => _bookingProcessEasyClear = val),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(
    String question, {
    bool isTextArea = false,
    bool isRating = false,
    bool isYesNo = false,
    bool isScore = false,
    TextEditingController? controller,
    int? rating,
    void Function(int)? onRatingChanged,
    bool? isYes,
    void Function(bool)? onYesNoChanged,
    int? score,
    void Function(int)? onScoreChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Lufga',
            color: Colors.black,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        if (isTextArea)
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: TextField(
              controller: controller,
              maxLines: 4,
              cursorColor: Colors.black,
              style: const TextStyle(fontFamily: 'Lufga', fontSize: 14),
              decoration: InputDecoration(
                hintText: "“Tell us more about your experience...”",
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontFamily: 'Lufga',
                  fontStyle: FontStyle.italic,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        if (isScore)
          Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: TextField(
              onChanged: (val) {
                if (onScoreChanged != null) {
                  onScoreChanged(int.tryParse(val) ?? 10);
                }
              },
              controller: TextEditingController(text: score.toString())
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: score.toString().length),
                ),
              cursorColor: Colors.black,
              style: const TextStyle(fontFamily: 'Lufga', fontSize: 16),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        if (isRating)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final isSelected = (rating ?? 5) > index;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (onRatingChanged != null) {
                    onRatingChanged(index + 1);
                  }
                },
                child: Column(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 38,
                      color: isSelected ? Colors.yellow[700] : Colors.grey[500],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getEmoji(index),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }),
          ),
        if (isYesNo)
          Row(
            children: [
              _buildCheckbox("Yes", (isYes ?? true), () {
                if (onYesNoChanged != null) onYesNoChanged(true);
              }),
              const SizedBox(width: 32),
              _buildCheckbox("No", !(isYes ?? true), () {
                if (onYesNoChanged != null) onYesNoChanged(false);
              }),
            ],
          ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.black : const Color(0xFFBCBCBC),
              ),
              color: isSelected ? Colors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.black : const Color(0xFFBCBCBC),
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getEmoji(int index) {
    switch (index) {
      case 0:
        return "😡";
      case 1:
        return "😔";
      case 2:
        return "😐";
      case 3:
        return "🙂";
      case 4:
        return "😍";
      default:
        return "";
    }
  }

  Widget _buildBottomButtons() {
    String buttonText = "${_currentPage + 1}/3 Next";
    if (_currentPage == 2) buttonText = "Submit Feedback";

    return BlocBuilder<FeedbackBloc, FeedbackState>(
      builder: (context, state) {
        final isLoading = state is FeedbackLoading;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OneBtn(
              text: isLoading ? "Submitting..." : buttonText,
              onPressed: isLoading
                  ? null
                  : () {
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutQuart,
                        );
                      } else {
                        _submitFeedback();
                      }
                    },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 4),
              ),
              child: const Text(
                "Skip",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lufga',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
