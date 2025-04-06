import 'package:flutter/cupertino.dart';

class DocFile {
  final String id;
  final String creatorId;
  final String title;
  final String fileName;
  final String mimetype;
  final int size;
  final DateTime? date;
  final String url;

  DocFile({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.fileName,
    required this.mimetype,
    required this.size,
    required this.date,
    required this.url,
  });

  factory DocFile.fromJson(Map<String, dynamic> json) {
    try {
      final String id = json['Id'] as String? ?? '';
      final String creatorId = json['CreatorId'] as String? ?? '';
      final String title = json['Title'] as String? ?? '';
      final String fileName = json['FileName'] as String? ?? '';
      final String mimetype = json['MIMEtype'] as String? ?? '';

      // Преобразуем размер, учитывая, что он может прийти как число или строка
      final int size = json['Size'] is int
          ? json['Size'] as int
          : int.tryParse(json['Size']?.toString() ?? '') ?? 0;

      final DateTime? date = json['Date'] != null
          ? DateTime.parse(json['Date'] as String)
          : null;
      final String url = json['URL'] as String? ?? '';

      return DocFile(
        id: id,
        creatorId: creatorId,
        title: title,
        fileName: fileName,
        mimetype: mimetype,
        size: size,
        date: date,
        url: url,
      );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге DocFile: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'CreatorId': creatorId,
      'Title': title,
      'FileName': fileName,
      'MIMEtype': mimetype,
      'Size': size,
      'Date': date?.toIso8601String(),
      'URL': url,
    };
  }
}
