import 'package:flutter/cupertino.dart';

import '../Users/UserCrop.dart';

class TestProfile {
  final int id;
  final String testTitle;
  final UserCrop creator;

  TestProfile({
    required this.id,
    required this.testTitle,
    required this.creator,
  });

  factory TestProfile.fromJson(Map<String, dynamic> json) {
    try {
    return TestProfile(
      id: json['Id'] as int? ?? 0,
      testTitle: json['TestTitle'] as String? ?? '',
      creator: UserCrop.fromJson((json['Creator'] as Map<String, dynamic>?) ?? {}),
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге TestProfile: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'TestTitle': testTitle,
      'Creator': creator.toJson(),
    };
  }
}
