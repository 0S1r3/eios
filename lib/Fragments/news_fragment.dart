import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';

import '../Optional/DateParser.dart';
import '../System_news/News.dart';
import '../Events/Events.dart';
import '../Token/MRSUAPI.dart';
import '../Token/SharedPrefManager.dart';
import 'Screens/NewsDetailScreen.dart';
import 'Screens/EventDetailScreen.dart';
import 'Screens/MyEventsScreen.dart';
import 'Screens/AllEventsScreen.dart';

/// Группирует список событий по датам (год, месяц, день)
Map<DateTime, List<Events>> groupEventsByDate(List<Events> events) {
  final Map<DateTime, List<Events>> eventsMap = {};
  for (var event in events) {
    final date = parseDate(event.startDate);
    if (date != null) {
      final key = DateTime(date.year, date.month, date.day);
      eventsMap.putIfAbsent(key, () => []).add(event);
    }
  }
  return eventsMap;
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<News>> _futureNews;
  late Future<List<Events>> _futureEventsForToday;
  late MrsuApi dataApi;
  late String _authHeader;

  final List<Color> _cardColors = [
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.yellow.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
  ];

  Map<DateTime, List<Events>> _eventsMap = {};
  DateTime? _selectedDay;

  final SharedPrefManager _manager = SharedPrefManager();

  bool _isRefreshingNews = false; // Флаг загрузки новостей

  @override
  void initState() {
    super.initState();
    _selectedDay =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    dataApi = MrsuApi.withBaseUrl('https://papi.mrsu.ru/');
    final accessToken = _manager.getAccessToken() ?? '';
    _authHeader = 'Bearer $accessToken';

    // Запрос новостей через API
    _futureNews = dataApi.getNews(_authHeader);

    // Загружаем общий список событий и сохраняем их в мапу
    dataApi.getEvents(_authHeader).then((eventsList) {
      setState(() {
        _eventsMap = groupEventsByDate(eventsList);
      });
      _manager.saveEvents(eventsList);
    });

    // Загружаем события для выбранной даты через Future
    _futureEventsForToday = _loadEventsForDayFuture(_selectedDay!);

    // Проверяем наличие обновлений для новостей и событий
    _checkForUpdates(_authHeader);
  }

  /// Получаем события для выбранного дня
  Future<List<Events>> _loadEventsForDayFuture(DateTime day) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(day);
    try {
      final eventsForDay = await dataApi.getEventsDate(_authHeader, formattedDate);
      setState(() {
        _eventsMap[DateTime(day.year, day.month, day.day)] = eventsForDay;
        _manager.saveEventsForDay(eventsForDay);
      });
      return eventsForDay;
    } catch (e) {
      // Если загрузка через API не удалась, пробуем взять кэшированные события для этой даты
      final cachedEvents = _manager.getEventsForDay() ?? [];
      final eventsForDay = cachedEvents.where((event) {
        final eventDate = parseDate(event.startDate);
        if (eventDate == null) return false;
        return DateTime(eventDate.year, eventDate.month, eventDate.day) ==
            DateTime(day.year, day.month, day.day);
      }).toList();
      setState(() {
        _eventsMap[DateTime(day.year, day.month, day.day)] = eventsForDay;
      });
      // Если кэшированных данных нет, возвращаем пустой список, чтобы отобразить кнопку "Обновить"
      return eventsForDay;
    }
  }

  /// Проверяем обновления новостей и событий через manager
  Future<void> _checkForUpdates(String authHeader) async {
    final bool newsUpdated = await _manager.isNewsUpdated(authHeader);
    if (newsUpdated) {
      final List<News> newNewsList = await dataApi.getNews(authHeader);
      await _manager.saveNews(newNewsList);
      setState(() {
        _futureNews = Future.value(newNewsList);
      });
    }

    final bool eventsUpdated = await _manager.isEventsUpdated(authHeader);
    if (eventsUpdated) {
      final List<Events> newEventsList = await dataApi.getEvents(authHeader);
      await _manager.saveEvents(newEventsList);
      setState(() {
        _eventsMap = groupEventsByDate(newEventsList);
      });
    }
  }

  /// Выбор даты через стандартный date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDay ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('ru', 'RU'),
    );
    if (pickedDate != null && pickedDate != _selectedDay) {
      setState(() {
        _selectedDay = pickedDate;
        _futureEventsForToday = _loadEventsForDayFuture(pickedDate);
      });
    }
  }

  /// Функция для обновления новостей с показом progress bar
  void _refreshNews() async {
    setState(() {
      _isRefreshingNews = true;
    });
    final newNews = await dataApi.getNews(_authHeader);
    _manager.saveNews(newNews);
    setState(() {
      _futureNews = Future.value(newNews);
      _isRefreshingNews = false;
    });
  }

  /// Функция для обновления событий для выбранного дня
  void _refreshEvents() async {
    if (_selectedDay != null) {
      final events = await _loadEventsForDayFuture(_selectedDay!);
      _manager.saveEventsForDay(events);
      setState(() {
        _futureEventsForToday = Future.value(events);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Новости'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Горизонтальный список новостей
                FutureBuilder<List<News>>(
                  future: _futureNews,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      // При ошибке пытаемся загрузить кэшированные новости
                      return FutureBuilder<List<News>>(
                        future: Future.value(_manager.getNews() ?? []),
                        builder: (context, cacheSnapshot) {
                          if (cacheSnapshot.hasData &&
                              (cacheSnapshot.data ?? []).isNotEmpty) {
                            final newsList = cacheSnapshot.data!;
                            return SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: newsList.length,
                                itemBuilder: (context, index) {
                                  final news = newsList[index];
                                  final Color cardColor =
                                  _cardColors[index % _cardColors.length];
                                  return Container(
                                    width: 300,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 16),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                NewsDetailScreen(news: news),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        elevation: 4,
                                        color: cardColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Html(
                                                data: news.header,
                                                style: {
                                                  "body": Style(
                                                    margin: Margins.zero,
                                                    padding: HtmlPaddings.zero,
                                                    fontSize: FontSize(18),
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                },
                                              ),
                                              const SizedBox(height: 8),
                                              Expanded(
                                                child: Text(
                                                  news.text.replaceAll(
                                                      RegExp(r'<[^>]*>'),
                                                      ''),
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  maxLines: 3,
                                                  style: const TextStyle(
                                                      color: Colors.black87),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Align(
                                                alignment: Alignment.bottomRight,
                                                child: Text(
                                                  formatDate(news.date),
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            return SizedBox(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Ошибка загрузки'),
                                    // Если идёт обновление, показываем progress bar, иначе кнопку
                                    _isRefreshingNews
                                        ? const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child:
                                      CircularProgressIndicator(),
                                    )
                                        : ElevatedButton(
                                      onPressed: _refreshNews,
                                      child: const Text('Обновить'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      );
                    } else if (!snapshot.hasData ||
                        (snapshot.data ?? []).isEmpty) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: Text('Новостей нет')),
                      );
                    }

                    final newsList = snapshot.data ?? [];
                    return SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: newsList.length,
                        itemBuilder: (context, index) {
                          final news = newsList[index];
                          final Color cardColor =
                          _cardColors[index % _cardColors.length];
                          return Container(
                            width: 300,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        NewsDetailScreen(news: news),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 4,
                                color: cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Html(
                                        data: news.header,
                                        style: {
                                          "body": Style(
                                            margin: Margins.zero,
                                            padding: HtmlPaddings.zero,
                                            fontSize: FontSize(18),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Text(
                                          news.text.replaceAll(
                                              RegExp(r'<[^>]*>'), ''),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                          style: const TextStyle(
                                              color: Colors.black87),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          formatDate(news.date),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const Divider(),
                // Блок выбора даты и отображения событий
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ряд с текстом и значком календаря
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'События на ${_selectedDay != null ? formatDate(_selectedDay!.toIso8601String()) : formatDate(DateTime.now().toIso8601String())}:',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // FutureBuilder для событий на выбранную дату
                      Container(
                        height: 150,
                        child: FutureBuilder<List<Events>>(
                          future: _futureEventsForToday,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              // Если основной источник данных пустой, пробуем взять кэш
                              List<Events> events = snapshot.data ?? [];
                              if (events.isEmpty && _selectedDay != null) {
                                final cachedEvents =
                                    _manager.getEventsForDay() ?? [];
                                events = cachedEvents.where((event) {
                                  final eventDate =
                                  parseDate(event.startDate);
                                  if (eventDate == null) return false;
                                  return DateTime(eventDate.year, eventDate.month,
                                      eventDate.day) ==
                                      DateTime(_selectedDay!.year,
                                          _selectedDay!.month,
                                          _selectedDay!.day);
                                }).toList();
                              }
                              if (events.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Событий нет'),
                                      ElevatedButton(
                                        onPressed: _refreshEvents,
                                        child: const Text('Обновить'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  final event = events[index];
                                  return ListTile(
                                    title: Text(event.title),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EventDetailScreen(event: event),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Кнопки перехода на экраны событий
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const MyEventsScreen()),
                              );
                            },
                            child: const Text('Мои события'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AllEventsScreen()),
                              );
                            },
                            child: const Text('Все события'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
