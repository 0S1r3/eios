import 'package:flutter/cupertino.dart';

class UserInfo {
  final String id;
  final bool isTeacher;
  final bool isStudent;
  final String fio;
  final String englishFio;

  UserInfo({
    required this.id,
    required this.isTeacher,
    required this.isStudent,
    required this.fio,
    required this.englishFio,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    try {
    return UserInfo(
      id: json['Id'] as String? ?? '',
      isTeacher: json['IsTeacher'] as bool? ?? false,
      isStudent: json['IsStudent'] as bool? ?? false,
      fio: json['FIO'] as String? ?? '',
      englishFio: json['EnglishFIO'] as String? ?? '',
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге UserInfo: $e\n$stackTrace');
      rethrow;
    }
  }


  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'IsTeacher': isTeacher,
      'IsStudent': isStudent,
      'FIO': fio,
      'EnglishFIO': englishFio,
    };
  }
}
