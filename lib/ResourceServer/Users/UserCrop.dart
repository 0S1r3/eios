import 'package:flutter/cupertino.dart';

import 'UserPhoto.dart';

class UserCrop {
  final String id;
  final String name;
  final String fio;
  final UserPhoto photo;

  UserCrop({
    required this.id,
    required this.name,
    required this.fio,
    required this.photo,
  });

  factory UserCrop.fromJson(Map<String, dynamic> json) {
    try {
    return UserCrop(
      id: json['Id'] as String? ?? '',
      name: json['UserName'] as String? ?? '',
      fio: json['FIO'] as String? ?? '',
      photo: UserPhoto.fromJson(json['Photo'] as Map<String, dynamic>? ?? {}),
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге UserCrop: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'UserName': name,
      'FIO': fio,
      'Photo': photo.toJson(),
    };
  }
}
