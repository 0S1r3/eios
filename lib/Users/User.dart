import 'package:flutter/cupertino.dart';

import '../ResourceServer/Users/Role.dart';
import '../ResourceServer/Users/UserPhoto.dart';

class User {
  final String email;
  final bool emailConfirmed;
  final String englishFio;
  final String teacherCod;
  final String studentCod;
  final String birthDate;
  final String academicDegree;
  final String academicRank;
  final List<Role> roles;
  final String id;
  final String userName;
  final String fio;
  final UserPhoto photo;

  User({
    required this.email,
    required this.emailConfirmed,
    required this.englishFio,
    required this.teacherCod,
    required this.studentCod,
    required this.birthDate,
    required this.academicDegree,
    required this.academicRank,
    required this.roles,
    required this.id,
    required this.userName,
    required this.fio,
    required this.photo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
    return User(
      email: json['Email'] as String? ?? '',
      emailConfirmed: json['EmailConfirmed'] as bool? ?? false,
      englishFio: json['EnglishFIO'] as String? ?? '',
      teacherCod: json['TeacherCod'] as String? ?? '',
      studentCod: json['StudentCod'] as String? ?? '',
      birthDate: json['BirthDate'] as String? ?? '',
      academicDegree: json['AcademicDegree'] as String? ?? '',
      academicRank: json['AcademicRank'] as String? ?? '',
      roles: (json['Roles'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      id: json['Id'] as String? ?? '',
      userName: json['UserName'] as String? ?? '',
      fio: json['FIO'] as String? ?? '',
      photo: UserPhoto.fromJson(json['Photo'] as Map<String, dynamic>),
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге User: $e\n$stackTrace');
      rethrow;
    }
  }


  Map<String, dynamic> toJson() {
    return {
      'Email': email,
      'EmailConfirmed': emailConfirmed,
      'EnglishFIO': englishFio,
      'TeacherCod': teacherCod,
      'StudentCod': studentCod,
      'BirthDate': birthDate,
      'AcademicDegree': academicDegree,
      'AcademicRank': academicRank,
      'Roles': roles.map((role) => role.toJson()).toList(),
      'Id': id,
      'UserName': userName,
      'FIO': fio,
      'Photo': photo.toJson(),
    };
  }
}
