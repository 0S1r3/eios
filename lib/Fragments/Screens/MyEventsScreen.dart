import 'package:flutter/material.dart';
import '../../Events/Events.dart';
import '../../Optional/DateParser.dart';
import '../../Token/MRSUAPI.dart';
import '../../Token/SharedPrefManager.dart';
import 'EventDetailScreen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  _MyEventsScreenState createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  late Future<List<Events>> _futureMyEvents;
  late MrsuApi dataApi;

  @override
  void initState() {
    super.initState();
    dataApi = MrsuApi.withBaseUrl('https://papi.mrsu.ru/');
    final manager = SharedPrefManager();
    final accessToken = manager.getAccessToken() ?? '';
    final authHeader = 'Bearer $accessToken';
    // Здесь используем getEventsMode с mode = 0 для получения событий,
    // где пользователь является создателем
    _futureMyEvents = dataApi.getEventsMode(authHeader, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои события'),
      ),
      body: FutureBuilder<List<Events>>(
        future: _futureMyEvents,
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
              // Форматирование дат
              final formattedStartTime = formatDate(event.startTime);
              final formattedEndTime = formatDate(event.endTime);
              return ListTile(
                title: Text(event.title),
                subtitle: Text('$formattedStartTime - $formattedEndTime\n${event.place}'),
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
