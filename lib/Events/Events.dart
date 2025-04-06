import 'package:flutter/cupertino.dart';

class Events {
  final int id;
  final String title;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String place;
  final String responsible;
  final bool isForAll;
  final String description;
  final bool status;
  final bool longEventMarker;
  final bool addTimeMarker;
  final String techInfo;
  final bool subscription;

  Events({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.place,
    required this.responsible,
    required this.isForAll,
    required this.description,
    required this.status,
    required this.longEventMarker,
    required this.addTimeMarker,
    required this.techInfo,
    required this.subscription,
  });

  factory Events.fromJson(Map<String, dynamic> json) {
    try {
    return Events(
      id: json['Id'] ?? 0,
      title: json['Наименование'] ?? '',
      startDate: json['ДатаНачало'] ?? '',
      endDate: json['ДатаОкончание'] ?? '',
      startTime: json['ВремяНачало'] ?? '',
      endTime: json['ВремяОкончание'] ?? '',
      place: json['Место'] ?? '',
      responsible: json['Ответственный'] ?? '',
      isForAll: json['IsForAll'] ?? false,
      description: json['Описание'] ?? '',
      status: json['status'] ?? false,
      longEventMarker: json['LongEventMarker'] ?? false,
      addTimeMarker: json['AddTimeMarker'] ?? false,
      techInfo: json['ТехИнфо'] ?? '',
      subscription: json['Подписка'] ?? false,
    );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при парсинге Events: $e\n$stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Наименование': title,
      'ДатаНачало': startDate,
      'ДатаОкончание': endDate,
      'ВремяНачало': startTime,
      'ВремяОкончание': endTime,
      'Место': place,
      'Ответственный': responsible,
      'IsForAll': isForAll,
      'Описание': description,
      'status': status,
      'LongEventMarker': longEventMarker,
      'AddTimeMarker': addTimeMarker,
      'ТехИнфо': techInfo,
      'Подписка': subscription,
    };
  }
}
