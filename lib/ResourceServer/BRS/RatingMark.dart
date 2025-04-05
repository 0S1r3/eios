import 'package:flutter/cupertino.dart';

class RatingMark {
  final int id;
  final double ball;
  final String creatorId;
  final String createDate;

  RatingMark({
    required this.id,
    required this.ball,
    required this.creatorId,
    required this.createDate,
  });

  factory RatingMark.fromJson(Map<String, dynamic> json) {
    try {
    return RatingMark(
      id: json['Id'] as int? ?? 0,
      ball: (json['Ball'] as num?)?.toDouble() ?? 0.0,
      creatorId: json['CreatorId'] as String? ?? '',
      createDate: json['CreateDate'] as String? ?? '',
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге RatingMark: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Ball': ball,
      'CreatorId': creatorId,
      'CreateDate': createDate,
    };
  }
}