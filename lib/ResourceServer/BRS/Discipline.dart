import 'package:flutter/cupertino.dart';

import '../DocFiles/DocFile.dart';

class Discipline {
  final bool relevance;
  final bool isTeacher;
  final int unreadedCount;
  final int unreadedMessageCount;
  final List<String> groups;
  final List<DocFile> docFiles;
  final List<DocFile> workingProgramm;
  final int id;
  final String planNumber;
  final String year;
  final String faculty;
  final String educationForm;
  final String educationLevel;
  final String speciality;
  final String specialityCod;
  final String profile;
  final String periodString;
  final int periodInt;
  final String title;
  final String language;

  Discipline({
    required this.relevance,
    required this.isTeacher,
    required this.unreadedCount,
    required this.unreadedMessageCount,
    required this.groups,
    required this.docFiles,
    required this.workingProgramm,
    required this.id,
    required this.planNumber,
    required this.year,
    required this.faculty,
    required this.educationForm,
    required this.educationLevel,
    required this.speciality,
    required this.specialityCod,
    required this.profile,
    required this.periodString,
    required this.periodInt,
    required this.title,
    required this.language,
  });

  factory Discipline.fromJson(Map<String, dynamic> json) {
    try {
      // Обработка поля WorkingProgramm: если это список, парсим как список,
      // если это Map, оборачиваем в список, иначе пустой список.
      List<DocFile> workingProgrammList;
      final workingProgrammData = json['WorkingProgramm'];
      if (workingProgrammData is List) {
        workingProgrammList = workingProgrammData
            .map((e) => DocFile.fromJson(e as Map<String, dynamic>? ?? {}))
            .toList();
      } else if (workingProgrammData is Map<String, dynamic>) {
        workingProgrammList = [DocFile.fromJson(workingProgrammData)];
      } else {
        workingProgrammList = [];
      }

      return Discipline(
        relevance: json['Relevance'] as bool? ?? false,
        isTeacher: json['IsTeacher'] as bool? ?? false,
        unreadedCount: json['UnreadedCount'] as int? ?? 0,
        unreadedMessageCount: json['UnreadedMessageCount'] as int? ?? 0,
        groups: (json['Groups'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
            [],
        docFiles: (json['DocFiles'] as List<dynamic>?)
            ?.map((e) =>
            DocFile.fromJson(e as Map<String, dynamic>? ?? {}))
            .toList() ??
            [],
        workingProgramm: workingProgrammList,
        id: json['Id'] as int? ?? 0,
        planNumber: json['PlanNumber'] as String? ?? '',
        year: json['Year'] as String? ?? '',
        faculty: json['Faculty'] as String? ?? '',
        educationForm: json['EducationForm'] as String? ?? '',
        educationLevel: json['EducationLevel'] as String? ?? '',
        speciality: json['Speciality'] as String? ?? '',
        specialityCod: json['SpecialityCod'] as String? ?? '',
        profile: json['Profile'] as String? ?? '',
        periodString: json['PeriodString'] as String? ?? '',
        periodInt: json['PeriodInt'] as int? ?? 0,
        title: json['Title'] as String? ?? '',
        language: json['Language'] as String? ?? '',
      );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге Discipline: $e\n$stackTrace');
      rethrow;
    }
  }


  Map<String, dynamic> toJson() {
    return {
      'Relevance': relevance,
      'IsTeacher': isTeacher,
      'UnreadedCount': unreadedCount,
      'UnreadedMessageCount': unreadedMessageCount,
      'Groups': groups,
      'DocFiles': docFiles.map((doc) => doc.toJson()).toList(),
      'WorkingProgramm': workingProgramm.map((doc) => doc.toJson()).toList(),
      'Id': id,
      'PlanNumber': planNumber,
      'Year': year,
      'Faculty': faculty,
      'EducationForm': educationForm,
      'EducationLevel': educationLevel,
      'Speciality': speciality,
      'SpecialityCod': specialityCod,
      'Profile': profile,
      'PeriodString': periodString,
      'PeriodInt': periodInt,
      'Title': title,
      'Language': language,
    };
  }
}
