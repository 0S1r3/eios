import 'package:intl/intl.dart';

// Функция для парсинга даты.
DateTime? parseDate(String dateStr) {
  if (dateStr.isEmpty) return null;
  try {
    return DateTime.parse(dateStr);
  } catch (e) {
    try {
      return DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}

// Функция для форматирования даты в формат dd.MM.yyyy
String formatDate(String dateStr) {
  final date = parseDate(dateStr);
  if (date != null) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
  return dateStr;
}