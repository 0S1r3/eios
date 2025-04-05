import 'package:flutter/cupertino.dart';

import '../DocFiles/DocFile.dart';

class StudentRatingPlanControlDotReport {
  final int id;
  final String createDate;
  final DocFile docFiles;

  StudentRatingPlanControlDotReport({
    required this.id,
    required this.createDate,
    required this.docFiles,
  });

  factory StudentRatingPlanControlDotReport.fromJson(Map<String, dynamic> json) {
    try {
      // Ожидаем, что поле "DocFile" содержит объект, а не список.
      final docFileJson = json['DocFile'] as Map<String, dynamic>? ?? {};
      return StudentRatingPlanControlDotReport(
        id: json['Id'] as int? ?? 0,
        createDate: json['CreateDate'] as String? ?? '',
        docFiles: DocFile.fromJson(docFileJson),
      );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге StudentRatingPlanControlDotReport: $e\n$stackTrace');
      rethrow;
    }
  }


  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'CreateDate': createDate,
      'DocFiles': docFiles.toJson(),
    };
  }
}
