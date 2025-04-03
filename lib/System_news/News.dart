import 'package:flutter/cupertino.dart';

class News {
  final int id;
  final String date;
  final String text;
  final String header;
  final bool viewed;

  News({
    required this.id,
    required this.date,
    required this.text,
    required this.header,
    required this.viewed,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    try {
    return News(
      id: json['Id'] != null ? json['Id'] as int : 0,
      date: json['Date'] != null ? json['Date'] as String : '',
      text: json['Text'] != null ? json['Text'] as String : '',
      header: json['Header'] != null ? json['Header'] as String : '',
      viewed: json['Viewed'] != null ? json['Viewed'] as bool : false,
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге News: $e\n$stackTrace');
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
