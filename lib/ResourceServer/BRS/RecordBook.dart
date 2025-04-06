import 'package:flutter/cupertino.dart';

import 'Discipline.dart';

class RecordBook {
  final String cod;
  final String number;
  final String faculty;
  final List<Discipline> discipline;

  RecordBook({
    required this.cod,
    required this.number,
    required this.faculty,
    required this.discipline,
  });

  factory RecordBook.fromJson(Map<String, dynamic> json) {
    try {
    return RecordBook(
      cod: json['Cod'] as String? ?? '',
      number: json['Number'] as String? ?? '',
      faculty: json['Faculty'] as String? ?? '',
      discipline: (json['Disciplines'] as List<dynamic>? ?? [])
          .map((e) => Discipline.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге RecordBook: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Cod': cod,
      'Number': number,
      'Faculty': faculty,
      'Disciplines': discipline.map((d) => d.toJson()).toList(),
    };
  }
}
