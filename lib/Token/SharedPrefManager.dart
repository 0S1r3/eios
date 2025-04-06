import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mrsu/ResourceServer/BRS/Semester.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../BRS/ForumMessage/ForumMessage.dart';
import '../BRS/StudentRatingPlan/StudentRatingPlan.dart';
import '../BRS/StudentSemester/StudentSemester.dart';
import '../Events/Events.dart';
import '../Optional/JsonEquals.dart';
import '../Users/User.dart';
import '../System_news/News.dart';
import '../TimeTable/StudentTimeTable.dart';
import 'MRSUAPI.dart';
import 'Token.dart';

class SharedPrefManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _studentDataKey = 'student_data';
  static const String _studentSemesterKey = 'student_semester';
  static const String _studentTimeTableKey = 'student_timetable';
  static const String _studentRatingPlanKey = 'student_ratingplan';
  static const String _forumMessageKey = 'forum_message';
  static const String _expirationTimeKey = 'expiration_time';
  static const String _newsKey = 'news';
  static const String _eventsKey = 'events';
  static const String _eventsForDayKey = 'eventsForDay';
  static const String _semesterKey = 'semester';

  // Новые ключи для настроек
  static const String _notificationsKey = 'notifications_enabled';
  static const String _extremeBetaKey = 'extreme_beta_enabled';

  static final SharedPrefManager _instance = SharedPrefManager._internal();
  SharedPreferences? _prefs;

  factory SharedPrefManager() {
    return _instance;
  }

  SharedPrefManager._internal();

  // Экземпляр API для получения токена (https://p.mrsu.ru/)
  late MrsuApi tokenApi;
  // Экземпляр API для остальных запросов (https://papi.mrsu.ru/)
  late MrsuApi dataApi;

  // Инициализация SharedPreferences.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    tokenApi = MrsuApi(); // базовый URL: https://p.mrsu.ru/
    dataApi = MrsuApi.withBaseUrl('https://papi.mrsu.ru/'); // базовый URL для остальных запросов

    // Если refreshToken уже сохранён, попробуем обновить accessToken.
    final refreshToken = getRefreshToken();
    if (refreshToken != null) {
      updateToken(refreshToken);
    }
  }

  // Сохраняет accessToken и refreshToken в SharedPreferences.
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _prefs?.setString(_accessTokenKey, accessToken);
    await _prefs?.setString(_refreshTokenKey, refreshToken);
  }

  // Сохраняет данные пользователя.
  Future<void> saveUserData(User user) async {
    final jsonUser = jsonEncode(user.toJson());
    await _prefs?.setString(_userDataKey, jsonUser);
  }

  // Сохраняет данные о семестре студента.
  Future<void> saveStudentSemester(StudentSemester semester) async {
    final jsonSemester = jsonEncode(semester.toJson());
    await _prefs?.setString(_studentSemesterKey, jsonSemester);
  }

  // Сохраняет рейтинг плана студента.
  Future<void> saveStudentRatingPlan(StudentRatingPlan plan) async {
    final jsonPlan = jsonEncode(plan.toJson());
    await _prefs?.setString(_studentRatingPlanKey, jsonPlan);
  }

  // Сохраняет расписание студента.
  Future<void> saveStudentTimeTable(List<StudentTimeTable> timeTable) async {
    final jsonTimeTable = jsonEncode(timeTable.map((e) => e.toJson()).toList());
    await _prefs?.setString(_studentTimeTableKey, jsonTimeTable);
  }

  // Сохраняет сообщения форума.
  Future<void> saveForumMessage(List<ForumMessage> messages) async {
    final jsonMessages = jsonEncode(messages.map((e) => e.toJson()).toList());
    await _prefs?.setString(_forumMessageKey, jsonMessages);
  }

  // Сохраняет токен с учетом времени его истечения.
  Future<void> saveToken(Token token) async {
    await _prefs?.setString(_accessTokenKey, token.accessToken);
    await _prefs?.setString(_refreshTokenKey, token.refreshToken);
    // Сохраняем время истечения (в миллисекундах). Добавляем небольшой запас (150 мс).
    final expTime = DateTime.now().millisecondsSinceEpoch + token.expiresIn * 1000 + 150;
    await _prefs?.setInt(_expirationTimeKey, expTime);
  }

  // Сохраняет новости.
  Future<void> saveNews(List<News> newsList) async {
    final jsonNews = jsonEncode(newsList.map((e) => e.toJson()).toList());
    await _prefs?.setString(_newsKey, jsonNews);
  }

  // Сохраняет события.
  Future<void> saveEvents(List<Events> newsList) async {
    final jsonEvents = jsonEncode(newsList.map((e) => e.toJson()).toList());
    await _prefs?.setString(_eventsKey, jsonEvents);
  }

  // Сохраняет события на текущий день.
  Future<void> saveEventsForDay(List<Events> newsList) async {
    final jsonEvents = jsonEncode(newsList.map((e) => e.toJson()).toList());
    await _prefs?.setString(_eventsForDayKey, jsonEvents);
  }

  // Сохраняет семестры.
  Future<void> saveSemester(List<Semester> newsList) async {
    final jsonEvents = jsonEncode(newsList.map((e) => e.toJson()).toList());
    await _prefs?.setString(_semesterKey, jsonEvents);
  }

  /// Методы для работы с новыми настройками
  ///
  // Сохраняет состояние уведомлений.
  Future<void> saveNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool(_notificationsKey, enabled);
  }

  // Возвращает состояние уведомлений.
  bool getNotificationsEnabled() {
    return _prefs?.getBool(_notificationsKey) ?? false;
  }

  // Сохраняет состояние функции extreme beta.
  Future<void> saveExtremeBetaEnabled(bool enabled) async {
    await _prefs?.setBool(_extremeBetaKey, enabled);
  }

  // Возвращает состояние функции extreme beta.
  bool getExtremeBetaEnabled() {
    return _prefs?.getBool(_extremeBetaKey) ?? false;
  }

  // Получает сохранённые данные пользователя.
  User? getUserData() {
    final jsonUser = _prefs?.getString(_userDataKey);
    if (jsonUser == null) return null;
    return User.fromJson(jsonDecode(jsonUser));
  }

  // Получает сохранённые данные о семестре студента.
  StudentSemester? getStudentSemester() {
    final jsonSemester = _prefs?.getString(_studentSemesterKey);
    if (jsonSemester == null) return null;
    return StudentSemester.fromJson(jsonDecode(jsonSemester));
  }

  // Получает сохранённые данные о рейтинг-плане студента.
  StudentRatingPlan? getStudentRatingPlan() {
    final jsonRatingPlan = _prefs?.getString(_studentRatingPlanKey);
    if (jsonRatingPlan == null) return null;
    return StudentRatingPlan.fromJson(jsonDecode(jsonRatingPlan));
  }

  // Получает расписание студента.
  List<StudentTimeTable>? getStudentTimeTable() {
    final jsonTimeTable = _prefs?.getString(_studentTimeTableKey);
    if (jsonTimeTable == null) return null;
    List<dynamic> list = jsonDecode(jsonTimeTable);
    return list.map((json) => StudentTimeTable.fromJson(json)).toList();
  }

  // Получает новости.
  List<News>? getNews() {
    final jsonNews = _prefs?.getString(_newsKey);
    if (jsonNews == null) return null;
    List<dynamic> list = jsonDecode(jsonNews);
    return list.map((json) => News.fromJson(json)).toList();
  }

  // Получает события.
  List<Events>? getEvents() {
    final jsonEvents = _prefs?.getString(_eventsKey);
    if (jsonEvents == null) return null;
    List<dynamic> list = jsonDecode(jsonEvents);
    return list.map((json) => Events.fromJson(json)).toList();
  }

  // Получает события на текущий день.
  List<Events>? getEventsForDay() {
    final jsonEvents = _prefs?.getString(_eventsForDayKey);
    if (jsonEvents == null) return null;
    List<dynamic> list = jsonDecode(jsonEvents);
    return list.map((json) => Events.fromJson(json)).toList();
  }

  // Получает семестры.
  List<Semester>? getSemester() {
    final jsonSemester = _prefs?.getString(_semesterKey);
    if (jsonSemester == null) return null;
    List<dynamic> list = jsonDecode(jsonSemester);
    return list.map((json) => Semester.fromJson(json)).toList();
  }

  // Возвращает сохранённый refreshToken.
  String? getRefreshToken() {
    return _prefs?.getString(_refreshTokenKey);
  }

  // Возвращает сохранённый accessToken.
  String? getAccessToken() {
    return _prefs?.getString(_accessTokenKey);
  }

  // Возвращает время истечения accessToken.
  int _getExpTime() {
    return _prefs?.getInt(_expirationTimeKey) ?? 0;
  }

  // Проверяет, истёк ли accessToken.
  bool _isAccessTokenExpired() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    return currentTime >= _getExpTime();
  }

  /// Проверка на обновление данных
  ///
  Future<bool> isStudentRatingPlanUpdated(String authorization, int id) async {
    try {
      final newPlan = await dataApi.getStudentRatingPlan(authorization, id);
      final storedJson = _prefs?.getString(_studentRatingPlanKey);

      if (storedJson == null) return true; // Если данных нет, значит обновились.

      final storedPlan = StudentRatingPlan.fromJson(jsonDecode(storedJson));

      return !deepEquals(newPlan.toJson(), storedPlan.toJson());
    } catch (e) {
      print("Ошибка при проверке обновления рейтинга студента: $e");
      return false; // В случае ошибки считаем, что данные не обновлены
    }
  }

  Future<bool> isStudentSemesterUpdated(String authorization) async {
    try {
      final newSemester = await dataApi.getStudentSemester(authorization);
      final storedJson = _prefs?.getString(_studentSemesterKey);

      if (storedJson == null) return true; // Если данных нет, значит обновились.

      final storedSemester = StudentSemester.fromJson(jsonDecode(storedJson));

      return !deepEquals(newSemester.toJson(), storedSemester.toJson());
    } catch (e) {
      print("Ошибка при проверке обновления семестра: $e");
      return false;
    }
  }

  Future<bool> isNewsUpdated(String authorization) async {
    try {
      final newNewsList = await dataApi.getNews(authorization);
      final storedJson = _prefs?.getString(_newsKey);

      if (storedJson == null) return true;

      List<dynamic> storedList = jsonDecode(storedJson);
      final storedNewsList = storedList.map((json) => News.fromJson(json)).toList();

      return !listEquals(newNewsList, storedNewsList);
    } catch (e) {
      print("Ошибка при проверке обновления новостей: $e");
      return false;
    }
  }

  Future<bool> isEventsUpdated(String authorization) async {
    try {
      final newEventsList = await dataApi.getEvents(authorization);
      final storedJson = _prefs?.getString(_eventsKey);

      if (storedJson == null) return true;

      List<dynamic> storedList = jsonDecode(storedJson);
      final storedEventsList = storedList.map((json) => Events.fromJson(json)).toList();

      return !listEquals(newEventsList, storedEventsList);
    } catch (e) {
      print("Ошибка при проверке обновления событий: $e");
      return false;
    }
  }

  Future<bool> isStudentTimeTableUpdated(String authorization, String date) async {
    try {
      final newTimeTable = await dataApi.getStudentTimeTable(authorization, date);
      final storedJson = _prefs?.getString(_studentTimeTableKey);

      if (storedJson == null) return true;

      List<dynamic> storedList = jsonDecode(storedJson);
      final storedTimeTable = storedList.map((json) => StudentTimeTable.fromJson(json)).toList();

      return !listEquals(newTimeTable, storedTimeTable);
    } catch (e) {
      print("Ошибка при проверке обновления расписания: $e");
      return false;
    }
  }

  // Создает Dio клиент с логированием запросов.
  Dio createDioClient(String baseUrl) {
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio;
  }

  // Обновляет токен с использованием refreshToken и получает обновленные данные пользователя.
  Future<void> updateToken(String refreshToken) async {
    try {
      final newToken = await tokenApi.getNewToken(refreshToken: refreshToken);
      await saveToken(newToken);

      // Формируем заголовок авторизации для запросов
      final authHeader = 'Bearer ${newToken.accessToken}';

      // Получаем данные пользователя через dataApi (papi.mrsu.ru)
      final user = await dataApi.getUser(authHeader);

      await saveUserData(user);
    } catch (e) {
      print("Ошибка обновления токена: $e");
    }
  }

  // Проверяет срок действия accessToken и, если необходимо, обновляет его.
  Future<void> checkTokenExpiration() async {
    if (_isAccessTokenExpired()) {
      final refreshToken = getRefreshToken();
      if (refreshToken != null) {
        await updateToken(refreshToken);
      }
    }
  }

  // Очищает все сохранённые данные.
  Future<void> clearTokens() async {
    await _prefs?.remove(_accessTokenKey);
    await _prefs?.remove(_refreshTokenKey);
    await _prefs?.remove(_userDataKey);
    await _prefs?.remove(_studentDataKey);
    await _prefs?.remove(_studentSemesterKey);
    await _prefs?.remove(_studentTimeTableKey);
    await _prefs?.remove(_studentRatingPlanKey);
    await _prefs?.remove(_forumMessageKey);
    await _prefs?.remove(_expirationTimeKey);
    await _prefs?.remove(_newsKey);
    await _prefs?.remove(_eventsKey);
    await _prefs?.remove(_semesterKey);
    await _prefs?.remove(_eventsForDayKey);
    // Очищаем настройки
    await _prefs?.remove(_notificationsKey);
    await _prefs?.remove(_extremeBetaKey);
  }
}
