import 'package:flutter/cupertino.dart';

class Token {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String refreshToken;

  Token({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    try {
    return Token(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
      refreshToken: json['refresh_token'] as String,
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге Token: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'refresh_token': refreshToken,
    };
  }
}
