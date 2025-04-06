import 'package:flutter/material.dart';
import '../../Events/Events.dart';
import '../../Optional/DateParser.dart';
import '../../Token/MRSUAPI.dart';
import '../../Token/SharedPrefManager.dart';
import 'EventDetailScreen.dart';

class AllEventsScreen extends StatefulWidget {
  const AllEventsScreen({super.key});

  @override
  _AllEventsScreenState createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  late Future<List<Events>> _futureAllEvents;
  late MrsuApi dataApi;

  @override
  void initState() {
    super.initState();
    // Инициализация API с базовым URL для запросов
    dataApi = MrsuApi.withBaseUrl('https://papi.mrsu.ru/');
    final manager = SharedPrefManager();
    final accessToken = manager.getAccessToken() ?? '';
    final authHeader = 'Bearer $accessToken';
    // Получение всех событий с сервера
    _futureAllEvents = dataApi.getEvents(authHeader);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Все события'),
      ),
      body: FutureBuilder<List<Events>>(
        future: _futureAllEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Событий не найдено'));
          }
          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              // Парсинг и форматирование дат
              final formattedStartDate = formatDate(event.startDate);
              final formattedEndDate = formatDate(event.endDate);
              return ListTile(
                title: Text(event.title),
                subtitle: Text(
                  '$formattedStartDate ${event.startTime} - $formattedEndDate ${event.endTime}\n${event.place}',
                ),
                isThreeLine: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(event: event),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
