
import 'package:flutter/cupertino.dart';

import '../../ResourceServer/BRS/RecordBook.dart';

class StudentSemester {
  final List<RecordBook> recordBooks;
  final int unreadedDisCount;
  final int unreadedDisMesCount;
  final String year;
  final int period;

  StudentSemester({
    required this.recordBooks,
    required this.unreadedDisCount,
    required this.unreadedDisMesCount,
    required this.year,
    required this.period,
  });

  factory StudentSemester.fromJson(Map<String, dynamic> json) {
    try {
    return StudentSemester(
      recordBooks: (json['RecordBooks'] as List<dynamic>? ?? [])
          .map((e) => RecordBook.fromJson(e as Map<String, dynamic>))
          .toList(),
      unreadedDisCount: json['UnreadedDisCount'] as int? ?? 0,
      unreadedDisMesCount: json['UnreadedDisMesCount'] as int? ?? 0,
      year: json['Year'] as String? ?? '',
      period: json['Period'] as int? ?? 0,
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге StudentSemester: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'RecordBooks': recordBooks.map((e) => e.toJson()).toList(),
      'UnreadedDisCount': unreadedDisCount,
      'UnreadedDisMesCount': unreadedDisMesCount,
      'Year': year,
      'Period': period,
    };
  }
}
