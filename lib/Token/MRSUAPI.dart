import 'package:dio/dio.dart';
import 'package:mrsu/ResourceServer/BRS/Discipline.dart';

import '../BRS/ForumMessage/ForumMessage.dart';
import '../BRS/StudentRatingPlan/StudentRatingPlan.dart';
import '../BRS/StudentSemester/StudentSemester.dart';
import '../Events/Events.dart';
import '../ResourceServer/BRS/Semester.dart';
import '../System_news/News.dart';
import '../Users/User.dart';
import '../TimeTable/StudentTimeTable.dart';
import 'Token.dart';

class MrsuApi {
  final Dio _dio;

  MrsuApi({Dio? dio})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: 'https://p.mrsu.ru/',
        ),
      ) {
    // Добавляем для логирования запросов и ответов
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      requestHeader: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  // Именованный конструктор для другого базового URL
  MrsuApi.withBaseUrl(String baseUrl, {Dio? dio})
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: baseUrl,
      )) {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      requestHeader: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  // GET v1/User
  Future<User> getUser(String authorization) async {
    final response = await _dio.get(
      'v1/User',
      options: Options(
        headers: {'Authorization': authorization},
      ),
    );
    return User.fromJson(response.data);
  }

  // GET v1/StudentSemester?year={year}&period={period}
  Future<StudentSemester> getStudentSemesterYearPeriod(String authorization, String date, int period) async {
    final response = await _dio.get(
      'v1/StudentSemester',
      queryParameters: {'year': date,
        'period': period},
      options: Options(
        headers: {'Authorization': authorization},
      ),
    );
    return StudentSemester.fromJson(response.data);
  }

  // GET v1/StudentSemester?selector=current
  Future<StudentSemester> getStudentSemester(String authorization) async {
    final response = await _dio.get(
      'v1/StudentSemester',
      queryParameters: {'selector': 'current'},
      options: Options(
        headers: {'Authorization': authorization},
      ),
    );
    return StudentSemester.fromJson(response.data);
  }

  // GET v1/StudentSemester
  Future<List<Semester>> getSemester(String authorization) async {
    final response = await _dio.get(
      'v1/StudentSemester',
      options: Options(
        headers: {'Authorization': authorization},
      ),
    );
    List<dynamic> data = response.data;
    return data.map((json) => Semester.fromJson(json)).toList();
  }

  // GET v1/StudentRatingPlan?id=...
  Future<StudentRatingPlan> getStudentRatingPlan(String authorization, int id) async {
    final response = await _dio.get(
      'v1/StudentRatingPlan',
      queryParameters: {'id': id},
      options: Options(
        headers: {'Authorization': authorization},
      ),
    );
    return StudentRatingPlan.fromJson(response.data);
  }

  // GET v1/Discipline/{id}
  Future<Discipline> getDiscipline(String authorization, int id) async {
    final response = await _dio.get(
      'v1/Discipline/$id',
      options: Options(
        headers: {'Authorization': authorization},
      ),
    );
    return Discipline.fromJson(response.data);
  }

  // GET v1/News
  Future<List<News>> getNews(String authorization) async {
    final response = await _dio.get(
      'v1/News',
      options: Options(
        headers: {'Authorization': authorization},
      ),
    );
    List<dynamic> data = response.data;
    return data.map((json) => News.fromJson(json)).toList();
  }

  // GET v1/Events
  Future<List<Events>> getEvents(String authorization) async {
    final response = await _dio.get(
      'v1/Events',
      options: Options(
        headers: {'Authorization': authorization},
      ),
    );
    List<dynamic> data = response.data;
    return data.map((json) => Events.fromJson(json)).toList();
  }

  // GET v1/Events?date={date}
  Future<List<Events>> getEventsDate(String authorization, String date) async {
    final response = await _dio.get(
      'v1/Events',
      queryParameters: {'date' : date},
      options: Options(
        headers: {'Authorization': authorization},
      ),
    );
    List<dynamic> data = response.data;
    return data.map((json) => Events.fromJson(json)).toList();
  }

  // GET v1/Events?mode={mode}
  // Режим mode: 0 - пользователь, как создатель событий;
  // 1 - пользователь, как участник событий;
  // 2 - пользователь, как организатор событий
  Future<List<Events>> getEventsMode(String authorization, int mode) async {
    final response = await _dio.get(
      'v1/Events',
      queryParameters: {'mode' : mode},
      options: Options(
        headers: {'Authorization': authorization},
      ),
    );
    List<dynamic> data = response.data;
    return data.map((json) => Events.fromJson(json)).toList();
  }

  // GET v1/StudentTimeTable?date=...
  Future<List<StudentTimeTable>> getStudentTimeTable(String authorization, String date) async {
    final response = await _dio.get(
      'v1/StudentTimeTable',
      queryParameters: {'date': date},
      options: Options(
        headers: {'Authorization': authorization},
      ),
    );
    List<dynamic> data = response.data;
    return data.map((json) => StudentTimeTable.fromJson(json)).toList();
  }

  // GET v1/ForumMessage?disciplineId=...
  Future<List<ForumMessage>> getForumMessage(String authorization, int disciplineId) async {
    final response = await _dio.get(
      'v1/ForumMessage',
      queryParameters: {'disciplineId': disciplineId},
      options: Options(
        headers: {'Authorization': authorization},
      ),
    );
    List<dynamic> data = response.data;
    return data.map((json) => ForumMessage.fromJson(json)).toList();
  }

  // POST v1/ForumMessage?disciplineId=$disciplineId
  Future<ForumMessage> postForumMessage(
      String authorization,
      int disciplineId,
      ForumMessage message,
      ) async {
    final response = await _dio.post(
      'v1/ForumMessage?disciplineId=$disciplineId',
      data: message.toJson(),
      options: Options(
        headers: {'Authorization': authorization},
        contentType: 'application/json',
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ForumMessage.fromJson(response.data);
    } else {
      throw Exception('Ошибка при отправке сообщения');
    }
  }

  // POST OAuth/Token для получения токена по логину и паролю
  Future<Token> getToken({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      'OAuth/Token',
      data: {
        'grant_type': 'password',
        'username': username,
        'password': password,
        'client_id': '8',
        'client_secret': 'qweasd',
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return Token.fromJson(response.data);
  }

  // POST OAuth/Token для обновления токена
  Future<Token> getNewToken({
    required String refreshToken,
  }) async {
    final response = await _dio.post(
      'OAuth/Token',
      data: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': '8',
        'client_secret': 'qweasd',
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return Token.fromJson(response.data);
  }

  // DELETE v1/ForumMessage/{id}
  Future<void> deleteMessage(String authorization, int id) async {
    final response = await _dio.delete(
      'v1/ForumMessage/$id',
      options: Options(
        headers: {'Authorization': authorization},
      ),
    );
    if (response.statusCode != 204) {
      throw Exception('Ошибка при удалении сообщения');
    }
  }

}


