import 'package:flutter/cupertino.dart';

import 'OldRatingPlanSectionType.dart';
import 'StudentRatingPlanControlDot.dart';

class StudentRatingPlanSection {
  final List<StudentRatingPlanControlDot> controlDots;
  final OldRatingPlanSectionType sectionType;
  final int id;
  final int order;
  final String title;
  final String description;
  final String creatorId;
  final String createDate;

  StudentRatingPlanSection({
    required this.controlDots,
    required this.sectionType,
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.createDate,
  });

  factory StudentRatingPlanSection.fromJson(Map<String, dynamic> json) {
    try {
    var controlDotsJson = json['ControlDots'] as List<dynamic>? ?? [];
    List<StudentRatingPlanControlDot> controlDotsList = controlDotsJson
        .map((item) => StudentRatingPlanControlDot.fromJson(item as Map<String, dynamic>? ?? {}))
        .toList();

    return StudentRatingPlanSection(
      controlDots: controlDotsList,
      // Метод fromJson у enum принимает String, поэтому используем проверку на null
      sectionType: OldRatingPlanSectionTypeExtension.fromJson(json['SectionType'] as int?),
      id: json['Id'] as int? ?? 0,
      order: json['Order'] as int? ?? 0,
      title: json['Title'] as String? ?? '',
      description: json['Description'] as String? ?? '',
      creatorId: json['CreatorId'] as String? ?? '',
      createDate: json['CreateDate'] as String? ?? '',
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге StudentRatingPlanSection: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'ControlDots': controlDots.map((item) => item.toJson()).toList(),
      'SectionType': sectionType.toJson(),
      'Id': id,
      'Order': order,
      'Title': title,
      'Description': description,
      'CreatorId': creatorId,
      'CreateDate': createDate,
    };
  }
}
