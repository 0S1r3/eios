import 'package:flutter/cupertino.dart';

import '../Users/UserCrop.dart';
import 'TimeTableLessonDisciplineType.dart';
import 'auditorium.dart';

class TimeTableLessonDiscipline {
  final int id;
  final String title;
  final String language;
  final TimeTableLessonDisciplineType lessonType;
  final bool remote;
  final String group;
  final int subgroupNumber; // Byte преобразуем в int
  final UserCrop teacher;
  final Auditorium? auditorium;

  TimeTableLessonDiscipline({
    required this.id,
    required this.title,
    required this.language,
    required this.lessonType,
    required this.remote,
    required this.group,
    required this.subgroupNumber,
    required this.teacher,
    this.auditorium,
  });

  factory TimeTableLessonDiscipline.fromJson(Map<String, dynamic> json) {
    try {
      return TimeTableLessonDiscipline(
        id: json['Id'] != null ? json['Id'] as int : 0,
        title: (json['Title'] ?? '') as String,
        language: (json['Language'] ?? '') as String,
        lessonType: json['LessonType'] != null
            ? TimeTableLessonDisciplineTypeExtension.fromJson(json['LessonType'] as int)
            : TimeTableLessonDisciplineType.defaultType,
        remote: json['Remote'] != null ? json['Remote'] as bool : false,
        group: (json['Group'] ?? '') as String,
        subgroupNumber: json['SubgroupNumber'] != null ? json['SubgroupNumber'] as int : 0,
        teacher: UserCrop.fromJson(json['Teacher'] as Map<String, dynamic>),
        auditorium: Auditorium.fromJson(json['Auditorium'] as Map<String, dynamic>),
      );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге TimeTableLessonDiscipline: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Title': title,
      'Language': language,
      'LessonType': lessonType.toJson(),
      'Remote': remote,
      'Group': group,
      'SubgroupNumber': subgroupNumber,
      'Teacher': teacher.toJson(),
      if (auditorium != null) 'Auditorium': auditorium!.toJson(), // Не добавляем, если null
    };
  }
}
