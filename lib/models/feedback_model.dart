class FeedbackRequest {
  final int ticketId;
  final String overallSatisfactionComment;
  final String chargerExpectationsComment;
  final int overallQualityRating;
  final int chargingSpeedRating;
  final String chargerDurabilityComment;
  final bool staffHelpfulProfessional;
  final int recommendationScore;
  final String likedMost;
  final String improveSuggestions;
  final int appExperienceScore;
  final bool bookingProcessEasyClear;

  FeedbackRequest({
    required this.ticketId,
    required this.overallSatisfactionComment,
    required this.chargerExpectationsComment,
    required this.overallQualityRating,
    required this.chargingSpeedRating,
    required this.chargerDurabilityComment,
    required this.staffHelpfulProfessional,
    required this.recommendationScore,
    required this.likedMost,
    required this.improveSuggestions,
    required this.appExperienceScore,
    required this.bookingProcessEasyClear,
  });

  Map<String, dynamic> toJson() {
    return {
      'ticket_id': ticketId,
      'overall_satisfaction_comment': overallSatisfactionComment,
      'charger_expectations_comment': chargerExpectationsComment,
      'overall_quality_rating': overallQualityRating,
      'charging_speed_rating': chargingSpeedRating,
      'charger_durability_comment': chargerDurabilityComment,
      'staff_helpful_professional': staffHelpfulProfessional,
      'recommendation_score': recommendationScore,
      'liked_most': likedMost,
      'improve_suggestions': improveSuggestions,
      'app_experience_score': appExperienceScore,
      'booking_process_easy_clear': bookingProcessEasyClear,
    };
  }
}

class FeedbackResponse {
  final bool success;
  final String message;
  final FeedbackData? data;

  FeedbackResponse({required this.success, required this.message, this.data});

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? FeedbackData.fromJson(json['data']) : null,
    );
  }
}

class FeedbackData {
  final FeedbackInfo? feedback;

  FeedbackData({this.feedback});

  factory FeedbackData.fromJson(Map<String, dynamic> json) {
    return FeedbackData(
      feedback: json['feedback'] != null
          ? FeedbackInfo.fromJson(json['feedback'])
          : null,
    );
  }
}

class FeedbackInfo {
  final int id;
  final int ticketId;
  final String submittedAt;

  FeedbackInfo({
    required this.id,
    required this.ticketId,
    required this.submittedAt,
  });

  factory FeedbackInfo.fromJson(Map<String, dynamic> json) {
    return FeedbackInfo(
      id: json['id'] ?? 0,
      ticketId: json['ticket_id'] ?? 0,
      submittedAt: json['submitted_at'] ?? '',
    );
  }
}
