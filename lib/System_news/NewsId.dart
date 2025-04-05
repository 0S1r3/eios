import 'package:flutter/cupertino.dart';

class NewsId {
  final int id;
  final String date;
  final String text;
  final String header;
  final bool viewed;

  NewsId({
    required this.id,
    required this.date,
    required this.text,
    required this.header,
    required this.viewed,
  });

  factory NewsId.fromJson(Map<String, dynamic> json) {
    try {
    return NewsId(
      id: json['Id'] != null ? json['Id'] as int : 0,
      date: json['Date'] != null ? json['Date'] as String : '',
      text: json['Text'] != null ? json['Text'] as String : '',
      header: json['Header'] != null ? json['Header'] as String : '',
      viewed: json['Viewed'] != null ? json['Viewed'] as bool : false,
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге NewsId: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Date': date,
      'Text': text,
      'Header': header,
      'Viewed': viewed,
    };
  }
}
