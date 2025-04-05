import 'package:flutter/cupertino.dart';
import 'TimeTableLessonDiscipline.dart';

class TimeTableLesson {
  final int number;
  final int subgroupCount;
  final List<TimeTableLessonDiscipline> disciplines;

  TimeTableLesson({
    required this.number,
    required this.subgroupCount,
    required this.disciplines,
  });

  factory TimeTableLesson.fromJson(Map<String, dynamic> json) {
    try {
      return TimeTableLesson(
        number: json['Number'] != null ? json['Number'] as int : 0,
        subgroupCount: json['SubgroupCount'] != null ? json['SubgroupCount'] as int : 0,
        disciplines: json['Disciplines'] != null
            ? (json['Disciplines'] as List)
            .map((item) => TimeTableLessonDiscipline.fromJson(Map<String, dynamic>.from(item)))
            .toList()
            : <TimeTableLessonDiscipline>[],
      );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге TimeTableLesson: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Number': number,
      'SubgroupCount': subgroupCount,
      'Disciplines': disciplines.map((item) => item.toJson()).toList(),
    };
  }
}
