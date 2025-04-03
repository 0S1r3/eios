import 'package:flutter/cupertino.dart';

import '../../ResourceServer/BRS/RatingMark.dart';
import '../../ResourceServer/BRS/StudentRatingPlanSection.dart';

class StudentRatingPlan {
  final RatingMark markZeroSession;
  final List<StudentRatingPlanSection> sections;

  StudentRatingPlan({
    required this.markZeroSession,
    required this.sections,
  });

  factory StudentRatingPlan.fromJson(Map<String, dynamic> json) {
    try {
    return StudentRatingPlan(
      markZeroSession: RatingMark.fromJson(
          json['MarkZeroSession'] as Map<String, dynamic>? ?? {}
      ),
      sections: (json['Sections'] as List<dynamic>? ?? [])
          .map((e) => StudentRatingPlanSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге StudentRatingPlan: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'MarkZeroSession': markZeroSession.toJson(),
      'Sections': sections.map((section) => section.toJson()).toList(),
    };
  }
}
