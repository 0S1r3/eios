import 'package:flutter/cupertino.dart';
import 'TimeTableLesson.dart';

class TimeTable {
  final String date;
  final List<TimeTableLesson> lessons;

  TimeTable({
    required this.date,
    required this.lessons,
  });

  factory TimeTable.fromJson(Map<String, dynamic> json) {
    try {
      return TimeTable(
        date: (json['Date'] ?? '') as String,
        lessons: json['Lessons'] != null
            ? (json['Lessons'] as List)
            .map((item) => TimeTableLesson.fromJson(Map<String, dynamic>.from(item)))
            .toList()
            : <TimeTableLesson>[],
      );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге TimeTable: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Date': date,
      'Lessons': lessons.map((lesson) => lesson.toJson()).toList(),
    };
  }
}
