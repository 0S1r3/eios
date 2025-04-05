import 'package:flutter/cupertino.dart';

class Semester {
  final String year;
  final int period;
  final int unreadedDisCount;
  final int unreadedDisMesCount;

  Semester({
    required this.unreadedDisCount,
    required this.unreadedDisMesCount,
    required this.year,
    required this.period,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    try {
    return Semester(
      unreadedDisCount: json['UnreadedDisCount'] as int? ?? 0,
      unreadedDisMesCount: json['UnreadedDisMesCount'] as int? ?? 0,
      year: json['Year'] as String? ?? '',
      period: json['Period'] as int? ?? 0,
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге Semester: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'UnreadedDisCount': unreadedDisCount,
      'UnreadedDisMesCount': unreadedDisMesCount,
      'Year': year,
      'Period': period,
    };
  }
}
