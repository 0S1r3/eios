import 'package:flutter/cupertino.dart';

import 'RatingMark.dart';
import 'StudentRatingPlanControlDotReport.dart';
import 'TestProfile.dart';

class StudentRatingPlanControlDot {
  final RatingMark mark;
  final StudentRatingPlanControlDotReport report;
  final int id;
  final int order;
  final String title;
  final String date;
  final double maxBall;
  final bool isReport;
  final bool isCredit;
  final String creatorId;
  final String createDate;
  final List<TestProfile> testProfiles;

  StudentRatingPlanControlDot({
    required this.mark,
    required this.report,
    required this.id,
    required this.order,
    required this.title,
    required this.date,
    required this.maxBall,
    required this.isReport,
    required this.isCredit,
    required this.creatorId,
    required this.createDate,
    required this.testProfiles,
  });

  factory StudentRatingPlanControlDot.fromJson(Map<String, dynamic> json) {
    try {
    return StudentRatingPlanControlDot(
      mark: RatingMark.fromJson(json['Mark'] as Map<String, dynamic>? ?? {}),
      report: StudentRatingPlanControlDotReport.fromJson(json['Report'] as Map<String, dynamic>? ?? {}),
      id: json['Id'] as int? ?? 0,
      order: json['Order'] as int? ?? 0,
      title: json['Title'] as String? ?? '',
      date: json['Date'] as String? ?? '',
      maxBall: (json['MaxBall'] as num?)?.toDouble() ?? 0.0,
      isReport: json['IsReport'] as bool? ?? false,
      isCredit: json['IsCredit'] as bool? ?? false,
      creatorId: json['CreatorId'] as String? ?? '',
      createDate: json['CreateDate'] as String? ?? '',
      testProfiles: (json['TestProfiles'] as List<dynamic>? ?? [])
          .map((e) => TestProfile.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге StudentRatingPlanControlDot: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Mark': mark.toJson(),
      'Report': report.toJson(),
      'Id': id,
      'Order': order,
      'Title': title,
      'Date': date,
      'MaxBall': maxBall,
      'IsReport': isReport,
      'IsCredit': isCredit,
      'CreatorId': creatorId,
      'CreateDate': createDate,
      'TestProfiles': testProfiles.map((e) => e.toJson()).toList(),
    };
  }
}
