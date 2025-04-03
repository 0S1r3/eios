import 'package:flutter/cupertino.dart';

class UserPhoto {
  final String urlSmall;
  final String urlMedium;
  final String urlSource;

  UserPhoto({
    required this.urlSmall,
    required this.urlMedium,
    required this.urlSource,
  });

  factory UserPhoto.fromJson(Map<String, dynamic> json) {
    try {
    return UserPhoto(
      urlSmall: json['UrlSmall'] != null ? json['UrlSmall'] as String : '',
      urlMedium: json['UrlMedium'] != null ? json['UrlMedium'] as String : '',
      urlSource: json['UrlSource'] != null ? json['UrlSource'] as String : '',
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге UserPhoto: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'UrlSmall': urlSmall,
      'UrlMedium': urlMedium,
      'UrlSource': urlSource,
    };
  }
}
