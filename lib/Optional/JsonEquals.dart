import 'package:collection/collection.dart';

// Сравнивает два JSON-объекта
bool deepEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
  const DeepCollectionEquality deepEquality = DeepCollectionEquality();
  return deepEquality.equals(a, b);
}

// Сравнивает два списка объектов
bool listEquals<T>(List<T> a, List<T> b) {
  const DeepCollectionEquality deepEquality = DeepCollectionEquality();
  return deepEquality.equals(a, b);
}
