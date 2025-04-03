import 'package:flutter/cupertino.dart';

class Auditorium {
  final int id;
  final String number;
  final String title;
  final int campusId;
  final String campusTitle;

  Auditorium({
    required this.id,
    required this.number,
    required this.title,
    required this.campusId,
    required this.campusTitle,
  });

  factory Auditorium.fromJson(Map<String, dynamic> json) {
    try {
    return Auditorium(
      id: json['Id'] != null ? json['Id'] as int : 0,
      number: json['Number'] != null ? json['Number'] as String : '',
      title: json['Title'] != null ? json['Title'] as String : '',
      campusId: json['CampusId'] != null ? json['CampusId'] as int : 0,
      campusTitle: json['CampusTitle'] != null ? json['CampusTitle'] as String : '',
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге Auditorium: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Number': number,
      'Title': title,
      'CampusId': campusId,
      'CampusTitle': campusTitle,
    };
  }
}
