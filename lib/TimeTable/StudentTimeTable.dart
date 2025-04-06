import 'package:flutter/cupertino.dart';
import '../ResourceServer/TimeTable/TimeTable.dart';

class StudentTimeTable {
  final String group;
  final String planNumber;
  final String facultyName;
  final int timeTableBlockd;
  final TimeTable timeTable;

  StudentTimeTable({
    required this.group,
    required this.planNumber,
    required this.facultyName,
    required this.timeTableBlockd,
    required this.timeTable,
  });

  factory StudentTimeTable.fromJson(Map<String, dynamic> json) {
    try {
      return StudentTimeTable(
        group: (json['Group'] ?? '') as String,
        planNumber: (json['PlanNumber'] ?? '') as String,
        facultyName: (json['FacultyName'] ?? '') as String,
        timeTableBlockd: json['TimeTableBlockd'] != null ? json['TimeTableBlockd'] as int : 0,
        timeTable: json['TimeTable'] != null
            ? TimeTable.fromJson(Map<String, dynamic>.from(json['TimeTable']))
            : TimeTable(date: '', lessons: []),
      );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге StudentTimeTable: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Group': group,
      'PlanNumber': planNumber,
      'FacultyName': facultyName,
      'TimeTableBlockd': timeTableBlockd,
      'TimeTable': timeTable.toJson(),
    };
  }
}
