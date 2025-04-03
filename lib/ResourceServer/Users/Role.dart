import 'package:flutter/cupertino.dart';

class Role {
  final String name;
  final String description;

  Role({
    required this.name,
    required this.description,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    try {
    return Role(
      name: json['Name'] as String? ?? '',
      description: json['Description'] as String? ?? '',
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге Role: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Description': description,
    };
  }
}
