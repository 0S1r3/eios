import 'package:flutter/cupertino.dart';

import '../../ResourceServer/Users/UserCrop.dart';

class ForumMessage {
  final int id;
  final UserCrop user;
  final bool isTeacher;
  final String createDate;
  final String text;

  ForumMessage({
    required this.id,
    required this.user,
    required this.isTeacher,
    required this.createDate,
    required this.text,
  });

  factory ForumMessage.fromJson(Map<String, dynamic> json) {
    try {
    return ForumMessage(
      id: json['Id'] as int,
      user: UserCrop.fromJson(json['User']),
      isTeacher: json['IsTeacher'] as bool,
      createDate: json['CreateDate'] as String? ?? '',
      text: json['Text'] as String? ?? '',
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге ForumMessage: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'User': user.toJson(),
      'IsTeacher': isTeacher,
      'CreateDate': createDate,
      'Text': text,
    };
  }
}